/** -*- c++ -*-
 * Copyright (C) 2008 Doug Judd (Zvents, Inc.)
 *
 * This file is part of Hypertable.
 *
 * Hypertable is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; version 2 of the
 * License, or any later version.
 *
 * Hypertable is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
 * 02110-1301, USA.
 */

#include "Common/Compat.h"
#include <cassert>
#include <cstdlib>

extern "C" {
#include <poll.h>
}

#include "AsyncComm/Comm.h"
#include "AsyncComm/ReactorFactory.h"

#include "Common/Error.h"
#include "Common/InetAddr.h"
#include "Common/Logger.h"
#include "Common/System.h"
#include "Common/Timer.h"

#include "Hyperspace/DirEntry.h"
#include "Hypertable/Lib/Config.h"

#include "Client.h"
#include "HqlCommandInterpreter.h"

using namespace std;
using namespace Hypertable;
using namespace Hyperspace;
using namespace Config;


Client::Client(const String &install_dir, const String &config_file,
               uint32_t default_timeout_ms)
  : m_timeout_ms(default_timeout_ms), m_install_dir(install_dir) {
  ScopedRecLock lock(rec_mutex);

  if (!properties)
    init_with_policy<DefaultCommPolicy>(0, 0);

  m_props = new Properties(config_file, file_desc());
  initialize();
}


Client::Client(const String &install_dir, uint32_t default_timeout_ms)
  : m_timeout_ms(default_timeout_ms), m_install_dir(install_dir) {
  ScopedRecLock lock(rec_mutex);

  if (!properties)
    init_with_policy<DefaultCommPolicy>(0, 0);

  if (m_install_dir.empty())
    m_install_dir = System::install_dir;

  m_props = properties;
  initialize();
}


void Client::create_table(const String &name, const String &schema) {
  m_master_client->create_table(name.c_str(), schema.c_str());
}

void Client::alter_table(const String &name, const String &alter_schema_str) {
  // Construct a new schema which is a merge of the existing schema
  // and the desired alterations.
  TableCache::iterator it = m_table_cache.find(name);
  SchemaPtr schema, alter_schema, final_schema;
  TableIdentifier table_id;
  TablePtr table;
  Schema::AccessGroup *final_ag;
  Schema::ColumnFamily *final_cf;
  String final_schema_str;

  if (it == m_table_cache.end()) {
    table = new Table(m_range_locator, m_conn_manager, m_hyperspace, name, m_timeout_ms);
    m_table_cache.insert(make_pair(name, table));
  }
  else
    table = it->second;

  schema = table->get_schema();
  alter_schema = Schema::new_instance(alter_schema_str.c_str(),
      alter_schema_str.length());
  if (!alter_schema->is_valid())
    HT_THROW(Error::BAD_SCHEMA, alter_schema->get_error_string());

  final_schema = new Schema(*(schema.get()));
  final_schema->incr_generation();

  foreach(Schema::AccessGroup *alter_ag, alter_schema->get_access_groups()) {
    // create a new access group if needed
    if(!final_schema->access_group_exists(alter_ag->name)) {
      final_ag = new Schema::AccessGroup();
      final_ag->name = alter_ag->name;
      final_ag->in_memory = alter_ag->in_memory;
      final_ag->blocksize = alter_ag->blocksize;
      final_ag->compressor = alter_ag->compressor;
      final_ag->bloom_filter = alter_ag->bloom_filter;
      if (!final_schema->add_access_group(final_ag)) {
        String error_msg = final_schema->get_error_string();
        delete final_ag;
        HT_THROW(Error::BAD_SCHEMA, error_msg);
      }
    }
    else {
      final_ag = final_schema->get_access_group(alter_ag->name);
    }
  }

  // go through each column family to be altered
  foreach(Schema::ColumnFamily *alter_cf,
        alter_schema->get_column_families()) {
    if (alter_cf->deleted) {
      if (!final_schema->drop_column_family(alter_cf->name))
        HT_THROW(Error::BAD_SCHEMA, final_schema->get_error_string());
    }
    else {
      // add column family
      if(final_schema->get_max_column_family_id() >= Schema::ms_max_column_id)
        HT_THROW(Error::TOO_MANY_COLUMNS, (String)"Attempting to add > "
                 + Schema::ms_max_column_id
                 + (String) " column families to table");
      final_schema->incr_max_column_family_id();
      final_cf = new Schema::ColumnFamily(*alter_cf);
      final_cf->id = (uint32_t) final_schema->get_max_column_family_id();
      final_cf->generation = final_schema->get_generation();

      if(!final_schema->add_column_family(final_cf)) {
        String error_msg = final_schema->get_error_string();
        delete final_cf;
        HT_THROW(Error::BAD_SCHEMA, error_msg);
      }
    }
  }

  final_schema->render(final_schema_str, true);
  try {
    m_master_client->alter_table(name.c_str(), final_schema_str.c_str());
  }
  catch (Exception &e) {
    // In case someone else has altered the table, refresh our
    // version of the schema and throw the error up
    if (e.code() == Error::MASTER_SCHEMA_GENERATION_MISMATCH) {
      refresh_table(name);
      HT_THROW(e.code(), e.what() +
          (String)" Table possibly altered by another client, try again");
    }
    HT_THROW(e.code(), e.what());
  }
}

Table *Client::open_table(const String &name, bool force) {
  TableCache::iterator it = m_table_cache.find(name);

  if (it != m_table_cache.end()) {
    if (!force && !it->second->not_found())
      return it->second.get();

    m_table_cache.erase(it);
  }
  Table *table = new Table(m_range_locator, m_conn_manager, m_hyperspace, name,
                           m_timeout_ms);
  m_table_cache.insert(make_pair(name, table));
  return table;
}

void Client::refresh_table(const String &name) {
  TableCache::iterator it = m_table_cache.find(name);

  if (it != m_table_cache.end()) {
    m_table_cache.erase(it);
  }
  Table *table = new Table(m_range_locator, m_conn_manager, m_hyperspace, name,
                           m_timeout_ms);
  m_table_cache.insert(make_pair(name, table));
}


uint32_t Client::get_table_id(const String &name) {
  // TODO: issue 11
  String table_file("/hypertable/tables/"); table_file += name;
  DynamicBuffer value_buf(0);
  Hyperspace::HandleCallbackPtr null_handle_callback;
  uint64_t handle;
  uint32_t uval;

  handle = m_hyperspace->open(table_file, OPEN_FLAG_READ, null_handle_callback);

  // Get the 'table_id' attribute. TODO use attr_get_i32
  m_hyperspace->attr_get(handle, "table_id", value_buf);

  m_hyperspace->close(handle);

  uval = (uint32_t)atoi((const char *)value_buf.base);

  return uval;
}


String Client::get_schema(const String &name) {
  String schema;

  m_master_client->get_schema(name.c_str(), schema);

  return schema;
}


void Client::get_tables(std::vector<String> &tables) {
  uint64_t handle;
  HandleCallbackPtr null_handle_callback;
  std::vector<Hyperspace::DirEntry> listing;

  handle = m_hyperspace->open("/hypertable/tables", OPEN_FLAG_READ,
                              null_handle_callback);

  m_hyperspace->readdir(handle, listing);

  for (size_t i=0; i<listing.size(); i++) {
    if (!listing[i].is_dir)
      tables.push_back(listing[i].name);
  }

  m_hyperspace->close(handle);
}


void Client::drop_table(const String &name, bool if_exists) {

  // remove it from cache
  TableCache::iterator it = m_table_cache.find(name);

  if (it != m_table_cache.end())
    m_table_cache.erase(it);

  m_master_client->drop_table(name.c_str(), if_exists);

}


void Client::shutdown() {
  m_master_client->shutdown();
}


HqlInterpreter *Client::create_hql_interpreter() {
  return new HqlInterpreter(this);
}


// ------------- PRIVATE METHODS -----------------

void Client::initialize() {
  uint32_t wait_time, remaining;

  m_comm = Comm::instance();
  m_conn_manager = new ConnectionManager(m_comm);

  if (m_timeout_ms == 0)
    m_timeout_ms = m_props->get_i32("Hypertable.Request.Timeout");

  m_hyperspace = new Hyperspace::Session(m_comm, m_props);

  Timer timer(m_timeout_ms, true);

  remaining = timer.remaining();
  wait_time = (remaining < 3000) ? remaining : 3000;

  while (!m_hyperspace->wait_for_connection(wait_time)) {

    if (timer.expired())
      HT_THROW_(Error::CONNECT_ERROR_HYPERSPACE);

    cout << "Waiting for connection to Hyperspace..." << endl;

    remaining = timer.remaining();
    wait_time = (remaining < 3000) ? remaining : 3000;
  }

  m_app_queue = new ApplicationQueue(1);
  m_master_client = new MasterClient(m_conn_manager, m_hyperspace, m_timeout_ms,
                                     m_app_queue);

  m_master_client->initiate_connection(0);

  m_range_locator = new RangeLocator(m_props, m_conn_manager, m_hyperspace,
                                     m_timeout_ms);
}
