return {
  ['wikilink'] = function(args, kwargs)
    -- 1. Validate inputs
    if not args[1] then return pandoc.Null() end
    local title = pandoc.utils.stringify(args[1])
    if title == "" then return pandoc.Null() end

    local label = nil
    if args[2] then
      label = pandoc.utils.stringify(args[2])
    end

    -- 2. Build the Wikipedia URL with underscores
    local page_slug = title:gsub(" ", "_")
    local url = "https://en.wikipedia.org/wiki/" .. page_slug

    -- 3. Resolve a clean, relative path to the icon
    -- This captures only the path from "_extensions" onward, preventing 
    -- Quarto from mangling absolute system paths into broken dot-paths.
    local script_path = PANDOC_SCRIPT_FILE or ""
    local rel_dir = script_path:match("(_extensions.*[/\\])") or "_extensions/wikilink/"
    local icon_path = rel_dir .. "wikipedia-icon.png"

    -- 4. Parse the size parameter with a strict fallback
    local size = "1.2em"
    if kwargs and kwargs["size"] then
      local parsed_size = pandoc.utils.stringify(kwargs["size"])
      if parsed_size ~= "" then
        size = parsed_size
      end
    end

    -- 5. Construct the Image element
    -- We inject the size directly into a CSS style attribute string.
    local img_attr = pandoc.Attr(
      "", -- id
      {}, -- classes
      {   -- key-value attributes
        style = string.format("width: %s; height: auto; vertical-align: -0.15em; display: inline-block; border: none; margin: 0;", size)
      }
    )
    
    local img = pandoc.Image({pandoc.Str("Wikipedia icon")}, icon_path, "Wikipedia", img_attr)

    -- 6. Assemble the link content
    local link_content = { img }
    
    if label and label ~= "" then
      table.insert(link_content, pandoc.Space())
      table.insert(link_content, pandoc.Str(label))
    end

    -- 7. Return the final hyperlink
    return pandoc.Link(link_content, url, title)
  end
}