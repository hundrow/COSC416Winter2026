# COSC416Winter2026

## Project

SciKey Project (Scientific Keywords)

AI and NLP for indexing French scientific publications.

## Background

HAL is an open archive where researchers can deposit publication metadata (books, articles,
conference proceedings, posters, preprints, etc.) and, when available, full text in open access. It also
contains research datasets and software repositories. HAL currently contains more than 3,760,000
references and nearly 1,400,000 scientific documents.

ScanR is a tool for exploring the French research and innovation system. Among other things, it
allows users to discover 800,000 authors and 4 million scientific publications, while showing the
links between them.

## Objective

Determine keywords that describe each publication based on title and abstract. Keyword suggestions
will be generated using current AI tools based on LLMs.

This objective requires a database, NLP/LLM processing tools, and ideally a full web user interface.

## Tasks and Deliverables

1. Design the database architecture to store publication metadata from HAL and all required fields.
2. Associate each publication with keywords obtained by analyzing abstracts using NLP and
	Transformers.
	- Optional: compare different LLMs on a data sample to evaluate result quality.
3. Align obtained keywords with Wikidata. Retrieve Wikidata identifiers (Q) and BNF IDs when
	available.
4. Create a database subset containing publications in the UPEC collection in HAL
	(https://hal.u-pec.fr/).
5. Associate each UPEC author with keywords from their publications, removing duplicates.
	- Optional: remove exotic keywords (those not consistent with the core graph).
	- Optional: weight keywords by frequency of use.
	- Optional: reconstruct a keyword hierarchy from general to specific, for example:
	  "quantum chromodynamics (Q238170)" < "quantum field theory (Q54505)" <
	  "field theory (Q1262328)" < "theoretical physics (Q18362)".
6. Compare the keywords obtained with those associated with the author in ScanR
	(https://scanr.enseignementsup-recherche.gouv.fr/search/authors).
7. Calculate a confidence rate representing the validity of the obtained keywords.
	- Optional: compare confidence rates by LLM used.
8. Develop a full web GUI that allows users to:
	- Retrieve for each author: author name, HAL publication ID, proposed Wikidata keywords,
	  Wikidata ID, BNF ID, confidence rate.
	- Build custom queries and export results.
	- Optional: build a mind map of UPEC researchers based on Wikidata keywords.
9. Deliverables:
	- Technical report in LaTeX describing the work and results.
	- Source code for each project stage uploaded to GitHub.

## Clients

- Gaetan Hains (Prof. Comp. Sc.), Paris East University, Paris, France.
- Helene Pipet (Documentary IT Manager), Paris East University, France,
  helene.pipet@u-pec.fr.
- Jean Bouyssou (Documentary IT Scientist), Paris East University, France,
  jean.bouyssou@u-pec.fr.