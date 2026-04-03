local syn = {
  ["LIST"] = "Print",
  ["JUMP"] = "Jumptoline",
  ["SET"] = "Setvar",
  ["SKIP"] = "SkipLine",
  ["INST"] = "Instruction",
  ["HALT"] = "Stop"
}
local op = {
  ["="]  = "Valueof",
  ["+"]  = "Addition",
  ["-"]  = "Subtraction",
  ["=="] = "Equal",
  ["<"]  = "LessThan",
  [">"]  = "GreaterThan"
}

local runtime = {}

function runtime.Print(args, state)
  local output = {}

  for i, v in ipairs(args) do
    local val = runtime.Valueof(v, state)
    table.insert(output, tostring(val))
  end

  print(table.concat(output, " "))
end

function runtime.Jumptoline(args, state)
  local rawTarget = args[1]
  local cleanTarget = rawTarget:gsub(":$", "")

  if tonumber(cleanTarget) then
    return tonumber(cleanTarget)
  end

  local line = state.labels[cleanTarget]
  if not line then
    error("Unknown label: " .. tostring(rawTarget))
  end

  return line
end


function runtime.Stop()
  return "HALT"
end

function runtime.SkipLine(args, state, currentPC)
  return currentPC + 2
end


function runtime.Valueof(a, state)
  if state.vars[a] ~= nil then
    return state.vars[a]
  end

  local num = tonumber(a)
  if num ~= nil then
    return num
  end

  return a -- fallback to raw string
end

function runtime.Addition(a, b)
  return a + b
end

function runtime.Subtraction(a, b)
  return a - b
end

function runtime.Equal(a, b)
  return a == b
end

function runtime.LessThan(a, b)
  return a < b
end

function runtime.GreaterThan(a, b)
  return a > b
end

function runtime.Instruction(args, state, currentPC)
  -- Example: INST x > 5 10
  
  local rawTarget = args[4]
  local cleanTarget = rawTarget:gsub(":$", "")

  local target = tonumber(cleanTarget) or state.labels[cleanTarget]

  if not target then
    error("Invalid jump target: " .. tostring(rawTarget))
  end


  local left = runtime.Valueof(args[1], state)
  local operator = args[2]
  local right = runtime.Valueof(args[3], state)
  

  local opFunc = runtime[op[operator]]

  if not opFunc then
    error("Invalid operator in INST: " .. tostring(operator))
  end

  local result = opFunc(left, right)

  if result then
    return target
  else
    return currentPC + 1
  end
end

local function run(program)
  local state = { vars = {} }
  local pc = 1 -- program counter
  -- Inside the while loop in the run function:
  

  
  
local function buildLabels(program)
  local labels = {}

  for i, line in ipairs(program) do
    local label = line:match("^(%w+):$")
    if label then
      labels[label] = i
    end
  end

  return labels
end

local state = { vars = {}, labels = buildLabels(program) }

  while pc <= #program do
    local line = program[pc]
    
    if line:match("^(%w+):$") then
      pc = pc + 1
    else
    
    
    local tokens = {}

    for word in line:gmatch("%S+") do
      table.insert(tokens, word)
    end

    local command = tokens[1]
    local funcName = syn[command]

    if not funcName then
      error("Unknown command: " .. tostring(command))
    end

    local func = runtime[funcName]
    local args = {}

    for i = 2, #tokens do
      table.insert(args, tokens[i])
    end

    local result = func(args, state, pc)

    if result == "HALT" then
      break
    elseif type(result) == "number" then
      pc = result
    else
      pc = pc + 1
      

      end
    end
  end
end



local function eval(expr, state)
  if #expr == 1 then
    return runtime.Valueof(expr[1], state)
  end

  local left = runtime.Valueof(expr[1], state)
  local operator = expr[2]
  local right = runtime.Valueof(expr[3], state)

  local opFunc = runtime[op[operator]]
  return opFunc(left, right)
end

function runtime.Setvar(args, state)
  local name = args[1]
  local value = eval({table.unpack(args, 2)}, state)
  state.vars[name] = value
end



local function readProgram()
  local program = {}

  while true do
    local line = io.read()
    if line == "HALT" then break end
    table.insert(program, line)
  end

  return program
end

local program = readProgram()
run(program)
