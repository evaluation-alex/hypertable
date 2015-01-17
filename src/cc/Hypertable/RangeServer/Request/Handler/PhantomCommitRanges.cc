/*
 * Copyright (C) 2007-2014 Hypertable, Inc.
 *
 * This file is part of Hypertable.
 *
 * Hypertable is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; version 3 of the
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

#include <Common/Compat.h>

#include "PhantomCommitRanges.h"

#include <Hypertable/RangeServer/RangeServer.h>

#include <Hypertable/Lib/RangeServer/Request/Parameters/PhantomCommitRanges.h>

#include <AsyncComm/ResponseCallback.h>

#include <Common/Error.h>
#include <Common/Logger.h>
#include <Common/Serialization.h>

using namespace Hypertable;
using namespace Hypertable::RangeServer::Request::Handler;

void PhantomCommitRanges::run() {
  ResponseCallback cb(m_comm, m_event);

  try {
    const uint8_t *ptr = m_event->payload;
    size_t remain = m_event->payload_len;
    Lib::RangeServer::Request::Parameters::PhantomCommitRanges params;
    params.decode(&ptr, &remain);
    m_range_server->phantom_commit_ranges(&cb, params.op_id(),params.location(),
                                          params.plan_generation(),
                                          params.range_specs());
  }
  catch (Exception &e) {
    HT_ERROR_OUT << e << HT_END;
    cb.error(e.code(), e.what());
    return;
  }
}
