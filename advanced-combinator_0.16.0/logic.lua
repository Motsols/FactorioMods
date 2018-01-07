local function resolve_signalID(type_and_name)
  local split = string.find(type_and_name, "/")
  local signal_type = string.sub(type_and_name, 1, split - 1)
  local signal_name = string.sub(type_and_name, split + 1)
  return { type = signal_type, name = signal_name }
end

local function resolve_entity(entity, target)
  if target == "this" then
    return entity
  end
  return { error = "Unable to resolve: " .. target }
end

local logic = {

  sum = {
    parameters = { "array" },
    result = "number",
    parse = function()
    end
  },
  network = {
    parameters = { "entity", "wire-color" },
    result = "array",
    parse = function(params, entity)
      local resolved = resolve_entity(entity, target)

      local wire_color = params[2]
      local wire_type
      if wire_color == "red" then
        wire_type = defines.wire_type.red
      elseif wire_color == "green" then
        wire_type = defines.wire_type.green
      else
        return { error = "Unknown wire color: " .. wire_color }
      end
      return function()
        -- to be implemented
      end
    end
  },
  green = {
    parameters = { "entity", "signal-id" },
    result = "number",
    parse = function(params, entity)
      local target = params[1]
      local signal_id = resolve_signalID(params[2])
      local resolved = resolve_entity(entity, target)

      return function()
        if not resolved.valid then
          -- invalidate this, it needs to be reparsed, or removed if there is no such entity at all
          return { error = "Invalid target entity" }
        end
        local network = resolved.get_circuit_network(defines.wire_type.green)
        if not network then
          return 0
        end
        return network.get_signal(signal_id)
      end
    end
  },
  const = {
    parameters = { "string" },
    result = "number",
    parse = function(params)
      local value = tonumber(params[1])
      return function() return value end
    end
  },
  array = {
    parameters = { "number" },
    varargs = true,
    result = "array",
    parse = function()
    end
  }



}


return { logic = logic, resolve_signalID = resolve_signalID }
