  local component = require("component")
  local gpu = component.gpu
  local os = require("os")
  
  local AJEMLER = {}
  
  local registers = {
      eax = 0,
      ebx = 0,
      ecx = 0,
      edx = 0,
      cmp_result = false
  }
  
  local labels = {}
  
  function AJEMLER.mv(destination, source)
      if registers[source] then
          registers[destination] = registers[source]
      else
          registers[destination] = tonumber(source)
      end
  end
  
  function AJEMLER.crt(destination, source)
      if registers[source] then
          registers[destination] = registers[destination] + registers[source]
      else
          registers[destination] = registers[destination] + tonumber(source)
      end
  end
  
  function AJEMLER.clprg()
      return registers.eax
  end
  
  function AJEMLER.cmp(reg, value)
      registers.cmp_result = (registers[reg] == tonumber(value))
  end
  
  function AJEMLER.jml(label)
      return labels[label]
  end
  
  function AJEMLER.jer(label)
      if registers.cmp_result then
          return labels[label]
      end
  end
  
  function AJEMLER.pas(time)
      os.sleep(time)
  end
  
  function AJEMLER.mgs_bd(text)
      gpu.set(1, 1, text)
  end
  
  function AJEMLER.execute(lines)
      for i, line in ipairs(lines) do
          local tokens = {}
          for token in line:gmatch("%S+") do
              table.insert(tokens, token)
          end
  
          if tokens[1] == "label" then
              labels[tokens[2]] = i
          end
      end
  
      local i = 1
      while i <= #lines do
          local tokens = {}
          for token in lines[i]:gmatch("%S+") do
              table.insert(tokens, token)
          end
  
          if tokens[1] == "mv" then
              AJEMLER.mv(tokens[2], tokens[3])
          elseif tokens[1] == "crt" then
              AJEMLER.crt(tokens[2], tokens[3])
          elseif tokens[1] == "mgs_bd" then
              AJEMLER.mgs_bd(table.concat(tokens, " ", 2))
          elseif tokens[1] == "clprg" then
              return AJEMLER.clprg()
          elseif tokens[1] == "cmp" then
              AJEMLER.cmp(tokens[2], tokens[3])
          elseif tokens[1] == "jml" then
              i = AJEMLER.jml(tokens[2])
          elseif tokens[1] == "pas" then
              AJEMLER.pas()
          elseif tokens[1] == "jer" then
              local new_i = AJEMLER.jer(tokens[2])
              if new_i then
                  i = new_i
              end
         end
          i = i + 1
      end
  end
  
  return AJEMLER
