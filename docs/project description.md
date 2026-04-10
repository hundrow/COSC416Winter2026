# SciKey Projet (Scientific keywords)

## AI and NLP for indexing French scientific publications

HAL is an open archive where researchers can deposit the metadata of their publications (books, articles, conference proceedings, posters, preprints, etc.) as well as the text of these publications in open access. It also contains research datasets and some software code repositories. HAL currently contains more than 3,760,000 references and nearly 1,400,000 scientific documents.

ScanR is a tool for exploring the French research and innovation system. Among other things, it allows users to discover 800,000 authors and 4 million scientific publications, all while characterizing and showing the links between them.

The aim of this project is to determine the keywords describing the content of each publication based on their title and abstract. Keyword suggestions will be made using current AI tools based on LLM.

This objective will obviously be achieved through the deployment of a database, the development of NLP and LLM software tools, and ideally, a full web user interface.

## Tasks and deliverables

1. Design the database architecture to store publication metadata from HAL as well as the various fields required for the project.
2. Associate each publication with keywords obtained by analyzing the abstract using natural language processing and Transformers.
	1. Optional: use different LLMs on a sample of data to compare the quality of the results obtained.
3. Align the keywords obtained with those contained in Wikidata. Retrieve Wikidata identifiers (Q.) and Bibliothèque nationale de France IDs when available.
4. Create a subset of the database containing publications in the UPEC collection in Hal (https://hal.u-pec.fr/ ).
5. Associate each UPEC author with the keywords from their various publications, removing duplicates.
	1. Optional: remove exotic keywords = those that are not consistent with the core of the graph.
	2. Optional: weight keywords according to the number of uses.
	3. Optional: reconstruct the keyword hierarchy from the most general one obtained: for example, "quantum chromodynamics (Q238170)“ < ”quantum field theory (Q54505)“ < ”field theory (Q1262328)" < theoretical physics (Q18362).
6. Compare the keywords obtained from your work with those associated with the author in the ScanR application (https://scanr.enseignementsup-recherche.gouv.fr/search/authors).
7. Based on this comparison, calculate a confidence rate representing the validity of the keywords obtained.
	1. Optional: Compare the confidence rate based on the LLM used.
8. Develop a full-web GUI interface that allows you to:
	- Retrieve the following information for each author: author name / HAL publication ID / Proposed Wikidata keywords / Wikidata ID / BNF ID / Confidence rate.
	- Build custom queries and export the results.
	- Optional: build a mind map of UPEC researchers based on the Wikidata keywords obtained.
9. Deliverables:
	- Write a technical report in LaTeX describing the work carried out and the results obtained.
	- Upload the source codes used at each stage of the project to Github.

## Clients

- Gaétan Hains (Prof. Comp. Sc.), Paris East University, Paris, France;
- Hélène Pipet (Documentary IT Manager), Paris East University, France, helene.pipet@u-pec.fr;
- Jean Bouyssou (Documentary IT Scientist), Paris East University, France, jean.bouyssou@u-pec.fr.