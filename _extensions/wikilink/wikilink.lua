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

    -- 2. Parse the lang parameter with a strict fallback to "en"
    local lang = "en"
    if kwargs and kwargs["lang"] then
      local parsed_lang = pandoc.utils.stringify(kwargs["lang"])
      if parsed_lang ~= "" then
        lang = parsed_lang
      end
    end

    -- 3. Build the Wikipedia URL with underscores
    local page_slug = title:gsub(" ", "_")
    local url = "https://" .. lang .. ".wikipedia.org/wiki/" .. page_slug

    -- 4. Resolve a clean, project-root-relative path to the icon
    -- This captures only the path from "_extensions" onward, preventing
    -- Quarto from mangling absolute system paths into broken dot-paths.
    local script_path = PANDOC_SCRIPT_FILE or ""
    local rel_dir = (script_path:match("(_extensions.*[/\\])") or "_extensions/wikilink/"):gsub("\\", "/")
    local icon_rel_path = rel_dir .. "wikipedia-icon.png"

    -- Make sure the icon file actually gets copied into the render output.
    quarto.doc.add_resource(icon_rel_path)

    -- A path like "_extensions/wikilink/icon.png" is resolved by the browser
    -- relative to the *current page's* location, not the project root. For
    -- documents nested in subdirectories of a website/book project this
    -- points at the wrong place. quarto.project.offset gives the relative
    -- path from the current document back to the project root, which we
    -- prepend so the icon resolves correctly no matter how deeply nested
    -- the referencing page is.
    local icon_path = icon_rel_path
    if quarto.project and quarto.project.offset then
      icon_path = pandoc.path.join({quarto.project.offset, icon_rel_path})
    end

    -- 5. Parse the size parameter with a strict fallback
    local size = "1.2em"
    if kwargs and kwargs["size"] then
      local parsed_size = pandoc.utils.stringify(kwargs["size"])
      if parsed_size ~= "" then
        size = parsed_size
      end
    end

    -- 6. Construct the Image element
    -- We inject the size directly into a CSS style attribute string.
    local img_attr = pandoc.Attr(
      "", -- id
      {}, -- classes
      {   -- key-value attributes
        style = string.format("width: %s; height: auto; vertical-align: -0.15em; display: inline-block; border: none; margin: 0;", size)
      }
    )

    local img = pandoc.Image({pandoc.Str("Wikipedia icon")}, icon_path, "Wikipedia", img_attr)

    -- 7. Assemble the link content
    local link_content = { img }

    if label and label ~= "" then
      table.insert(link_content, pandoc.Space())
      table.insert(link_content, pandoc.Str(label))
    end

    -- 8. Return the final hyperlink
    return pandoc.Link(link_content, url, title)
  end
}
