---
title: "Lexeme"
date: 2018-03-07T20:55:51+11:00
draft: true
description: "A command-line constructed language word database, generation, and
declension program."
---

*Available on [GitHub](https://github.com/kdelwat/lexeme).*

Lexeme is a command-line constructed language word database, generation, and
declension program. It has a number of useful features:

- Words are saved in a searchable and filterable SQLite database.
- Generate words according to a basic syllable rule, or use advanced rules to specify unique patterns for different parts of speech.
- Apply custom phonotactics rules during word generation.
- Tag words with custom fields, for example gender or vowel harmony type, and filter the database according to any field.
- Batch generate words from file.
- Set declension rules and autodecline or conjugate words to different tenses, aspects, cases, or any other desired form.
- Automatically convert words to their phonetic representation through specified rules.
- Export database to a csv file compatible with [PolyGlot](https://draquet.github.io/PolyGlot/) or spreadsheet software.
- Easy file-based configuration.

{{< figure src="/images/Lexeme1.jpg" title="Generating a word" alt="Lexeme word generation prompt">}}
{{< figure src="/images/Lexeme1.jpg" title="Declining a word" alt="Lexeme word declension prompt">}}

