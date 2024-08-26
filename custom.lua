-- Filters (excluding docx)
if not FORMAT:match 'docx' then
  -- Your existing code here
  function Div(div)
    if div.classes:includes("learning-activity") then
      return quarto.Callout({
        type = "note",
        content = div.content,
        title = div.attributes.title and ("Learning Activity: " .. div.attributes.title) or "Learning Activity",
        appearance = div.attributes.appearance or "default",
        icon = div.attributes.icon or false
      })
    end
    -- note
    if div.classes:includes("note") then
      return quarto.Callout({
        type = "note",
        content = div.content,
        appearance = div.attributes.appearance or "simple",
        icon = div.attributes.icon or false
      })
    end
  end
end

-- Docx Filters
if FORMAT:match 'docx' then
  local in_callout = false
-- Work-around
  local function process_div(div)
    -- learning-activity
        -- re-purposes"callout-note"
    if div.classes:includes("learning-activity") then
      if not in_callout then
        in_callout = true
        local result = quarto.Callout({
          type = "note",
          content = pandoc.walk_block(pandoc.Div(div.content), {Div = process_div}),
          title = div.attributes.title and ("Learning Activity: " .. div.attributes.title) or "Learning Activity",
          appearance = div.attributes.appearance or "default",
          icon = div.attributes.icon or false
        })
        in_callout = false
        return result
      else
        return div
      end
    -- note
    elseif div.classes:includes("note") then
      if not in_callout then
        in_callout = true
        local result = quarto.Callout({
          type = "note",
          content = pandoc.walk_block(pandoc.Div(div.content), {Div = process_div}),
          appearance = div.attributes.appearance or "simple",
          icon = div.attributes.icon or false
        })
        in_callout = false
        return result
      else
        return div
      end
    else
      return pandoc.walk_block(div, {Div = process_div})
    end
  end
  function Div(div)
    return process_div(div)
  end
  -- remove bookmarks from headings  
  function Header(el)
    el.identifier = ""
    return el
  end
end