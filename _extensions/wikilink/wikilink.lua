-- 1. Helper variable to hold our image data so we only load it once.
local icon_data_uri = nil

return {
  ['wikilink'] = function(args, kwargs)
    -- 2. Ensure we have an argument for the Wikipedia page title
    if not args[1] then
      return pandoc.Null()
    end
    
    local title = pandoc.utils.stringify(args[1])
    if title == "" then
      return pandoc.Null()
    end

    -- 3. Check for an optional display label (the second argument)
    local label = nil
    if args[2] then
      label = pandoc.utils.stringify(args[2])
    end

    -- 4. Convert the title to a valid Wikipedia URL (replace spaces with underscores)
    local page_slug = title:gsub(" ", "_")
    local url = "https://en.wikipedia.org/wiki/" .. page_slug

    -- 5. Load and base64 encode the icon lazily (only runs the first time the shortcode is used)
    if not icon_data_uri then
      -- PANDOC_SCRIPT_FILE is a built-in variable containing the exact path to this script
      local script_path = PANDOC_SCRIPT_FILE or ""
      -- Extract the directory path from the script path
      local dir = script_path:match("(.*[/\\])") or "./"
      local icon_path = dir .. "wikipedia-icon.png"

      local f = io.open(icon_path, "rb")
      if f then
        local binary_data = f:read("*all")
        f:close()
        -- Encode the binary data into a Data URI so it embeds directly into the HTML
        icon_data_uri = "data:image/png;base64," .. quarto.base64.encode(binary_data)
      else
        icon_data_uri = "" -- Fallback if file is missing
      end
    end

    -- 6. Construct the image attributes (handling the optional 'size' parameter)
    local size = "1em"
    if kwargs and kwargs["size"] then
      size = pandoc.utils.stringify(kwargs["size"])
    end
    
    local attr = pandoc.Attr(
      "", -- identifier
      {}, -- classes
      {   -- key-value HTML attributes
        width = size,
        style = "vertical-align: -0.15em; display: inline-block; border: none;"
      }
    )

    -- 7. Create the Pandoc Image element
    -- Arguments: caption inlines, source URL, title string, attributes
    local caption = { pandoc.Str("Wikipedia icon") }
    local img = pandoc.Image(caption, icon_data_uri, "Wikipedia", attr)

    -- 8. Build the content of the link
    local link_content = { img }
    
    -- If a label was provided, add a space and the label text after the icon
    if label and label ~= "" then
      table.insert(link_content, pandoc.Space())
      table.insert(link_content, pandoc.Str(label))
    end

    -- 9. Return the complete hyperlink wrapping our content
    return pandoc.Link(link_content, url, title)
  end
}