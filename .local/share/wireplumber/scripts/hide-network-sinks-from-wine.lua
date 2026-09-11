-- Hide RAOP/AirPlay sinks from Wine/Proton clients.
--
-- Wine's PulseAudio driver probes *every* sink at process startup:
-- pulse_test_connect() -> pulse_probe_settings() -> pa_stream_connect_playback()
-- against each named sink, to learn its native rate/format/period. For a RAOP
-- sink that opens the RTSP session to the speaker, which makes the speaker
-- switch to this machine's AirPlay input and drop whatever it was playing.
-- module-raop-sink only tears the session down on an explicit Suspend, so it
-- then sits there holding the speaker with silence.
--
-- Dropping the permission for those nodes on Wine's PipeWire client means the
-- sinks are never listed to it, so there is nothing for it to probe. Same
-- mechanism client/access-portal.lua uses to hide camera nodes.
--
-- Note: the client match cannot be an ObjectManager Constraint.
-- application.process.binary is not one of the registry's global properties for
-- a client, so an Interest on it never matches; it is only readable from the
-- bound object's properties, hence the explicit check in is_hidden_from().

log = Log.open_topic ("s-client")

-- clients matching any of these binaries must not see the sinks below
blocked_binaries = { "^wine" }

nodes_om = ObjectManager {
  Interest {
    type = "node",
    Constraint { "media.class", "=", "Audio/Sink" },
    Constraint { "node.name", "matches", "raop_sink.*" },
  }
}

clients_om = ObjectManager { Interest { type = "client" } }

function is_hidden_from (client)
  local binary = client.properties["application.process.binary"]
  if binary == nil then
    return false
  end
  for _, pattern in ipairs (blocked_binaries) do
    if binary:match (pattern) then
      return true
    end
  end
  return false
end

function hide_all_from (client)
  local perms = {}
  for node in nodes_om:iterate () do
    perms[node["bound-id"]] = "-"
  end
  if next (perms) ~= nil then
    log:info (client, "hiding network sinks from "
        .. tostring (client.properties["application.process.binary"]))
    client:update_permissions (perms)
  end
end

clients_om:connect ("object-added", function (om, client)
  if is_hidden_from (client) then
    hide_all_from (client)
  end
end)

-- a sink discovered while a Wine client is already connected
nodes_om:connect ("object-added", function (om, node)
  for client in clients_om:iterate () do
    if is_hidden_from (client) then
      log:info (client, "hiding new network sink " .. tostring (node.properties["node.name"]))
      client:update_permissions { [node["bound-id"]] = "-" }
    end
  end
end)

nodes_om:activate ()
clients_om:activate ()
