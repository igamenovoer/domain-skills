# Academic Graph API

Base URL: `https://api.semanticscholar.org/graph/v1`

Official docs: https://api.semanticscholar.org/api-docs/graph

Set `x-api-key` in the request header when an API key is configured.

## POST /author/batch — Get details for multiple authors at once

| Name | In | Required | Type | Description |
| --- | --- | --- | --- | --- |
| fields | query | no | string | A comma-separated list of the fields to be returned. See the contents of Response Schema below for a list of all available fields that can be returned. The `authorId` field is... |
| payload | body | yes | object |  |

```bash
curl -s \
  -X POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "x-api-key: $S2_API_KEY" \
  -d '{"ids": ["<id>"]}' \
  "https://api.semanticscholar.org/graph/v1/author/batch?fields=name,affiliations"
```

## GET /author/search — Search for authors by name

| Name | In | Required | Type | Description |
| --- | --- | --- | --- | --- |
| offset | query | no | integer | Used for pagination. When returning a list of results, start with the element at this position in the list. |
| limit | query | no | integer | The maximum number of results to return. Must be <= 1000 |
| fields | query | no | string | A comma-separated list of the fields to be returned. See the contents of the `data` array in Response Schema below for a list of all available fields that can be returned. The... |
| query | query | yes | string | A plain-text search query string. * No special query syntax is supported. * Hyphenated query terms yield no matches (replace it with space to find matches) |

```bash
curl -s \
  -H "Accept: application/json" \
  -H "x-api-key: $S2_API_KEY" \
  "https://api.semanticscholar.org/graph/v1/author/search?query=<search query>"
```

## GET /author/{author_id} — Details about an author

| Name | In | Required | Type | Description |
| --- | --- | --- | --- | --- |
| fields | query | no | string | A comma-separated list of the fields to be returned. See the contents of Response Schema below for a list of all available fields that can be returned. The `authorId` field is... |
| author_id | path | yes | string |  |

```bash
curl -s \
  -H "Accept: application/json" \
  -H "x-api-key: $S2_API_KEY" \
  "https://api.semanticscholar.org/graph/v1/author/{author_id}?fields=name,affiliations"
```

## GET /author/{author_id}/papers — Details about an author's papers

| Name | In | Required | Type | Description |
| --- | --- | --- | --- | --- |
| publicationDateOrYear | query | no | string | Restricts results to the given range of publication dates or years (inclusive). Accepts the format `:` with each date in `YYYY-MM-DD` format. Each term is optional, allowing... |
| offset | query | no | integer | Used for pagination. When returning a list of results, start with the element at this position in the list. |
| limit | query | no | integer | The maximum number of results to return. Must be <= 1000 |
| fields | query | no | string | A comma-separated list of the fields to be returned. See the contents of the `data` array in Response Schema below for a list of all available fields that can be returned. The... |
| author_id | path | yes | string |  |

```bash
curl -s \
  -H "Accept: application/json" \
  -H "x-api-key: $S2_API_KEY" \
  "https://api.semanticscholar.org/graph/v1/author/{author_id}/papers?fields=name,affiliations"
```

## GET /paper/autocomplete — Suggest paper query completions

| Name | In | Required | Type | Description |
| --- | --- | --- | --- | --- |
| query | query | yes | string | Plain-text partial query string. Will be truncated to first 100 characters. |

```bash
curl -s \
  -H "Accept: application/json" \
  -H "x-api-key: $S2_API_KEY" \
  "https://api.semanticscholar.org/graph/v1/paper/autocomplete?query=<search query>"
```

## POST /paper/batch — Get details for multiple papers at once

| Name | In | Required | Type | Description |
| --- | --- | --- | --- | --- |
| fields | query | no | string | A comma-separated list of the fields to be returned. See the contents of Response Schema below for a list of all available fields that can be returned. The `paperId` field is... |
| payload | body | yes | object |  |

```bash
curl -s \
  -X POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "x-api-key: $S2_API_KEY" \
  -d '{"ids": ["<id>"]}' \
  "https://api.semanticscholar.org/graph/v1/paper/batch?fields=title,abstract"
```

## GET /paper/search — Paper relevance search

| Name | In | Required | Type | Description |
| --- | --- | --- | --- | --- |
| query | query | yes | string | A plain-text search query string. * No special query syntax is supported. * Hyphenated query terms yield no matches (replace it with space to find matches) See our [blog... |
| fields | query | no | string | A comma-separated list of the fields to be returned. See the contents of the `data` array in Response Schema below for a list of all available fields that can be returned. The... |
| publicationTypes | query | no | string | Restricts results to any of the following paper publication types: ; Review ; JournalArticle ; CaseReport ; ClinicalTrial ; Conference ; Dataset ; Editorial ;... |
| openAccessPdf | query | no | string | Restricts results to only include papers with a public PDF. This parameter does not accept any values. |
| minCitationCount | query | no | string | Restricts results to only include papers with the minimum number of citations. Example: `minCitationCount=200` |
| publicationDateOrYear | query | no | string | Restricts results to the given range of publication dates or years (inclusive). Accepts the format `:` with each date in `YYYY-MM-DD` format. Each term is optional, allowing... |
| year | query | no | string | Restricts results to the given publication year or range of years (inclusive). Examples: ; `2019` in 2019 ; `2016-2020` as early as 2016 or as late as 2020 ; `2010-` during or... |
| venue | query | no | string | Restricts results to papers published in the given venues, formatted as a comma-separated list. Input could also be an ISO4 abbreviation. Examples include: ; Nature ; New... |
| fieldsOfStudy | query | no | string | Restricts results to papers in the given fields of study, formatted as a comma-separated list: ; Computer Science ; Medicine ; Chemistry ; Biology ; Materials Science ; Physics... |
| offset | query | no | integer | Used for pagination. When returning a list of results, start with the element at this position in the list. |
| limit | query | no | integer | The maximum number of results to return. Must be <= 100 |

```bash
curl -s \
  -H "Accept: application/json" \
  -H "x-api-key: $S2_API_KEY" \
  "https://api.semanticscholar.org/graph/v1/paper/search?query=<search query>"
```

## GET /paper/search/bulk — Paper bulk search

| Name | In | Required | Type | Description |
| --- | --- | --- | --- | --- |
| query | query | yes | string | Text query that will be matched against the paper's title and abstract. All terms are stemmed in English. By default all terms in the query must be present in the paper. The... |
| token | query | no | string | Used for pagination. This string token is provided when the original query returns, and is used to fetch the next batch of papers. Each call will return a new token. |
| fields | query | no | string | A comma-separated list of the fields to be returned. See the contents of the `data` array in Response Schema below for a list of all available fields that can be returned. The... |
| sort | query | no | string | Provides the option to sort the results by the following fields: ; `paperId` ; `publicationDate` ; `citationCount` Uses the format `field:order`. Ties are broken by `paperId`.... |
| publicationTypes | query | no | string | Restricts results to any of the following paper publication types: ; Review ; JournalArticle ; CaseReport ; ClinicalTrial ; Conference ; Dataset ; Editorial ;... |
| openAccessPdf | query | no | string | Restricts results to only include papers with a public PDF. This parameter does not accept any values. |
| minCitationCount | query | no | string | Restricts results to only include papers with the minimum number of citations. Example: `minCitationCount=200` |
| publicationDateOrYear | query | no | string | Restricts results to the given range of publication dates or years (inclusive). Accepts the format `:` with each date in `YYYY-MM-DD` format. Each term is optional, allowing... |
| year | query | no | string | Restricts results to the given publication year or range of years (inclusive). Examples: ; `2019` in 2019 ; `2016-2020` as early as 2016 or as late as 2020 ; `2010-` during or... |
| venue | query | no | string | Restricts results to papers published in the given venues, formatted as a comma-separated list. Input could also be an ISO4 abbreviation. Examples include: ; Nature ; New... |
| fieldsOfStudy | query | no | string | Restricts results to papers in the given fields of study, formatted as a comma-separated list: ; Computer Science ; Medicine ; Chemistry ; Biology ; Materials Science ; Physics... |

```bash
curl -s \
  -H "Accept: application/json" \
  -H "x-api-key: $S2_API_KEY" \
  "https://api.semanticscholar.org/graph/v1/paper/search/bulk?query=<search query>"
```

## GET /paper/search/match — Paper title search

| Name | In | Required | Type | Description |
| --- | --- | --- | --- | --- |
| query | query | yes | string | A plain-text search query string. * No special query syntax is supported. See our [blog... |
| fields | query | no | string | A comma-separated list of the fields to be returned. See the contents of the `data` array in Response Schema below for a list of all available fields that can be returned. The... |
| publicationTypes | query | no | string | Restricts results to any of the following paper publication types: ; Review ; JournalArticle ; CaseReport ; ClinicalTrial ; Conference ; Dataset ; Editorial ;... |
| openAccessPdf | query | no | string | Restricts results to only include papers with a public PDF. This parameter does not accept any values. |
| minCitationCount | query | no | string | Restricts results to only include papers with the minimum number of citations. Example: `minCitationCount=200` |
| publicationDateOrYear | query | no | string | Restricts results to the given range of publication dates or years (inclusive). Accepts the format `:` with each date in `YYYY-MM-DD` format. Each term is optional, allowing... |
| year | query | no | string | Restricts results to the given publication year or range of years (inclusive). Examples: ; `2019` in 2019 ; `2016-2020` as early as 2016 or as late as 2020 ; `2010-` during or... |
| venue | query | no | string | Restricts results to papers published in the given venues, formatted as a comma-separated list. Input could also be an ISO4 abbreviation. Examples include: ; Nature ; New... |
| fieldsOfStudy | query | no | string | Restricts results to papers in the given fields of study, formatted as a comma-separated list: ; Computer Science ; Medicine ; Chemistry ; Biology ; Materials Science ; Physics... |

```bash
curl -s \
  -H "Accept: application/json" \
  -H "x-api-key: $S2_API_KEY" \
  "https://api.semanticscholar.org/graph/v1/paper/search/match?query=<search query>"
```

## GET /paper/{paper_id} — Details about a paper

| Name | In | Required | Type | Description |
| --- | --- | --- | --- | --- |
| paper_id | path | yes | string | The following types of IDs are supported: ; `` - a Semantic Scholar ID, e.g. `649def34f8be52c8b66281af98ae884c09aef38b` ; `CorpusId:` - a Semantic Scholar numerical ID, e.g.... |
| fields | query | no | string | A comma-separated list of the fields to be returned. See the contents of Response Schema below for a list of all available fields that can be returned. The `paperId` field is... |

```bash
curl -s \
  -H "Accept: application/json" \
  -H "x-api-key: $S2_API_KEY" \
  "https://api.semanticscholar.org/graph/v1/paper/{paper_id}?fields=title,abstract"
```

## GET /paper/{paper_id}/authors — Details about a paper's authors

| Name | In | Required | Type | Description |
| --- | --- | --- | --- | --- |
| offset | query | no | integer | Used for pagination. When returning a list of results, start with the element at this position in the list. |
| limit | query | no | integer | The maximum number of results to return. Must be <= 1000 |
| fields | query | no | string | A comma-separated list of the fields to be returned. See the contents of the `data` array in Response Schema below for a list of all available fields that can be returned. The... |
| paper_id | path | yes | string | The following types of IDs are supported: ; `` - a Semantic Scholar ID, e.g. `649def34f8be52c8b66281af98ae884c09aef38b` ; `CorpusId:` - a Semantic Scholar numerical ID, e.g.... |

```bash
curl -s \
  -H "Accept: application/json" \
  -H "x-api-key: $S2_API_KEY" \
  "https://api.semanticscholar.org/graph/v1/paper/{paper_id}/authors?fields=name,affiliations"
```

## GET /paper/{paper_id}/citations — Details about a paper's citations

| Name | In | Required | Type | Description |
| --- | --- | --- | --- | --- |
| publicationDateOrYear | query | no | string | Restricts results to the given range of publication dates or years (inclusive). Accepts the format `:` with each date in `YYYY-MM-DD` format. Each term is optional, allowing... |
| offset | query | no | integer | Used for pagination. When returning a list of results, start with the element at this position in the list. |
| limit | query | no | integer | The maximum number of results to return. Must be <= 1000 |
| fields | query | no | string | A comma-separated list of the fields to be returned. See the contents of the `data` array in Response Schema below for a list of all available fields that can be returned. If... |
| paper_id | path | yes | string | The following types of IDs are supported: ; `` - a Semantic Scholar ID, e.g. `649def34f8be52c8b66281af98ae884c09aef38b` ; `CorpusId:` - a Semantic Scholar numerical ID, e.g.... |

```bash
curl -s \
  -H "Accept: application/json" \
  -H "x-api-key: $S2_API_KEY" \
  "https://api.semanticscholar.org/graph/v1/paper/{paper_id}/citations?fields=title,abstract"
```

## GET /paper/{paper_id}/references — Details about a paper's references

| Name | In | Required | Type | Description |
| --- | --- | --- | --- | --- |
| offset | query | no | integer | Used for pagination. When returning a list of results, start with the element at this position in the list. |
| limit | query | no | integer | The maximum number of results to return. Must be <= 1000 |
| fields | query | no | string | A comma-separated list of the fields to be returned. See the contents of the `data` array in Response Schema below for a list of all available fields that can be returned. If... |
| paper_id | path | yes | string | The following types of IDs are supported: ; `` - a Semantic Scholar ID, e.g. `649def34f8be52c8b66281af98ae884c09aef38b` ; `CorpusId:` - a Semantic Scholar numerical ID, e.g.... |

```bash
curl -s \
  -H "Accept: application/json" \
  -H "x-api-key: $S2_API_KEY" \
  "https://api.semanticscholar.org/graph/v1/paper/{paper_id}/references?fields=title,abstract"
```

## GET /snippet/search — Text snippet search

| Name | In | Required | Type | Description |
| --- | --- | --- | --- | --- |
| fields | query | no | string | A comma-separated list of the fields to be returned with each snippet element. Paper info and the score are currently always returned. What you can specify using this `fields`... |
| paperIds | query | no | string | Restricts results to snippets from specific papers. To specify papers, provide a comma-separated list of their IDs. You can provide up to approximately 100 IDs. The following... |
| authors | query | no | string | Restricts results to papers with authors matching the given names, formatted as a comma-separated list (`...?authors=name1,name2,...`). The search criteria are 'fuzzy', so... |
| minCitationCount | query | no | string | Restricts results to only include papers with the minimum number of citations. Example: `minCitationCount=200` |
| insertedBefore | query | no | string | Restricts results to snippets from papers inserted into the index before the provided date (excludes things inserted on the provided date). Acceptable formats: YYYY-MM-DD,... |
| publicationDateOrYear | query | no | string | Restricts results to the given range of publication dates or years (inclusive). Accepts the format `:` with each date in `YYYY-MM-DD` format. Each term is optional, allowing... |
| year | query | no | string | Restricts results to the given publication year or range of years (inclusive). Examples: ; `2019` in 2019 ; `2016-2020` as early as 2016 or as late as 2020 ; `2010-` during or... |
| venue | query | no | string | Restricts results to papers published in the given venues, formatted as a comma-separated list. Input could also be an ISO4 abbreviation. Examples include: ; Nature ; New... |
| fieldsOfStudy | query | no | string | Restricts results to papers in the given fields of study, formatted as a comma-separated list: ; Computer Science ; Medicine ; Chemistry ; Biology ; Materials Science ; Physics... |
| query | query | yes | string | A plain-text search query string. * No special query syntax is supported. |
| limit | query | no | integer | The maximum number of results to return. Must be <= 1000 |

```bash
curl -s \
  -H "Accept: application/json" \
  -H "x-api-key: $S2_API_KEY" \
  "https://api.semanticscholar.org/graph/v1/snippet/search?query=<search query>"
```
