# Quarto Wikilink Extension

A Quarto shortcode extension to insert linked Wikipedia icons into documents.

## Installation

```bash
quarto add CarwilB/quarto-wikilink
```

## Usage

```markdown
<!-- Icon only -->
{{< wikilink "Margaret Mead" >}}

<!-- Icon + linked text label -->
{{< wikilink "Margaret Mead" "Margaret Mead" >}}

<!-- Custom size -->
{{< wikilink "Margaret Mead" size="1.2em" >}}
```