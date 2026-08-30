local icon_data_uri = nil
local icon_path_absolute = nil

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

    -- 2. Build the Wikipedia URL
    local page_slug = title:gsub(" ", "_")
    local url = "https://en.wikipedia.org/wiki/" .. page_slug

    -- 3. Resolve the absolute path to the bundled icon
    if not icon_path_absolute then
      local script_path = PANDOC_SCRIPT_FILE or ""
      local dir = script_path:match("(.*[/\\])") or "./"
      icon_path_absolute = dir .. "wikipedia-icon.png"
    end

    -- 4. Parse the size parameter (defaulting to 1.2em)
    local size = "1.2em"
    if kwargs and kwargs["size"] then
      size = pandoc.utils.stringify(kwargs["size"])
    end

    local link_content = {}
    
    -- 5. Branch rendering logic based on output format
    if quarto.doc.is_format("html:js") or quarto.doc.is_format("html") or pandoc.FORMAT:match("html") then
      
      -- Load and Base64 encode the icon lazily for HTML
      if not icon_data_uri then
        local f = io.open(icon_path_absolute, "rb")
        if f then
          local binary_data = f:read("*all")
          f:close()
          icon_data_uri = "data:image/png;base64," .. quarto.base64.encode(binary_data)
        else
          icon_data_uri = ""
        end
      end
      
      -- Output raw HTML to strictly enforce CSS scaling and prevent attribute stripping
      local img_html = string.format(
        '<img src="%s" alt="Wikipedia" style="width: %s; height: auto; vertical-align: -0.15em; display: inline-block; border: none; margin: 0;" />',
        icon_data_uri, size
      )
      table.insert(link_content, pandoc.RawInline('html', img_html))
      
    else
      -- PDF / LaTeX / DOCX Fallback: Use standard Pandoc Image with absolute file path
      local attr = pandoc.Attr("", {}, {width = size})
      local img = pandoc.Image({pandoc.Str("Wikipedia icon")}, icon_path_absolute, "Wikipedia", attr)
      table.insert(link_content, img)
    end

    -- 6. Append the optional text label
    if label and label ~= "" then
      table.insert(link_content, pandoc.Space())
      table.insert(link_content, pandoc.Str(label))
    end

    -- 7. Return the final hyperlink
    return pandoc.Link(link_content, url, title)
  end
}