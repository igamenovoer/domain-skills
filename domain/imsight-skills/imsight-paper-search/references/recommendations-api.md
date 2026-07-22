# Recommendations API

Base URL: `https://api.semanticscholar.org/recommendations/v1`

Official docs: https://api.semanticscholar.org/api-docs/recommendations

Set `x-api-key` in the request header when an API key is configured.

## POST /papers/ — Get recommended papers for lists of positive and negative example papers

| Name | In | Required | Type | Description |
| --- | --- | --- | --- | --- |
| limit | query | no | integer | How many recommendations to return. Maximum 500. |
| fields | query | no | string | A comma-separated list of the fields to be returned. See the contents of the `recommendedPapers` array in Response Schema below for a list of all available fields that can be... |
| payload | body | yes | object |  |

```bash
curl -s \
  -X POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "x-api-key: $S2_API_KEY" \
  -d '{"positivePaperIds": ["<id>"]}' \
  "https://api.semanticscholar.org/recommendations/v1/papers/?fields=title,abstract"
```

## GET /papers/forpaper/{paper_id} — Get recommended papers for a single positive example paper

| Name | In | Required | Type | Description |
| --- | --- | --- | --- | --- |
| from | query | no | string | Which pool of papers to recommend from. |
| limit | query | no | integer | How many recommendations to return. Maximum 500. |
| fields | query | no | string | A comma-separated list of the fields to be returned. See the contents of the `recommendedPapers` array in Response Schema below for a list of all available fields that can be... |
| paper_id | path | yes | string |  |

```bash
curl -s \
  -H "Accept: application/json" \
  -H "x-api-key: $S2_API_KEY" \
  "https://api.semanticscholar.org/recommendations/v1/papers/forpaper/{paper_id}?fields=title,abstract"
```
