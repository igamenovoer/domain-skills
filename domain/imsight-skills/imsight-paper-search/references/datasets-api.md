# Datasets API

Base URL: `https://api.semanticscholar.org/datasets/v1`

Official docs: https://api.semanticscholar.org/api-docs/datasets

Use an API key only when one is available. First check the shell environment variable `S2_API_KEY`; if it is not set, check common environment files such as `.env` or `.env.local` in the working directory. If a non-empty `S2_API_KEY` value is found, include `-H "x-api-key: $S2_API_KEY"` in the curl command.

## GET /diffs/{start_release_id}/to/{end_release_id}/{dataset_name} — Download Links for Incremental Diffs

| Name | In | Required | Type | Description |
| --- | --- | --- | --- | --- |
| dataset_name | path | yes | string | Name of the dataset |
| end_release_id | path | yes | string | ID of the release the client wishes to update to, or 'latest' for the most recent release |
| start_release_id | path | yes | string | ID of the release held by the client |

```bash
curl -s \
  -H "Accept: application/json" \
  -H "x-api-key: $S2_API_KEY" \
  "https://api.semanticscholar.org/datasets/v1/diffs/{start_release_id}/to/{end_release_id}/{dataset_name}"
```

## GET /release/ — List of Available Releases

```bash
curl -s \
  -H "Accept: application/json" \
  -H "x-api-key: $S2_API_KEY" \
  "https://api.semanticscholar.org/datasets/v1/release/"
```

## GET /release/{release_id} — List of Datasets in a Release

| Name | In | Required | Type | Description |
| --- | --- | --- | --- | --- |
| release_id | path | yes | string | ID of the release |

```bash
curl -s \
  -H "Accept: application/json" \
  -H "x-api-key: $S2_API_KEY" \
  "https://api.semanticscholar.org/datasets/v1/release/{release_id}"
```

## GET /release/{release_id}/dataset/{dataset_name} — Download Links for a Dataset

| Name | In | Required | Type | Description |
| --- | --- | --- | --- | --- |
| dataset_name | path | yes | string | Name of the dataset |
| release_id | path | yes | string | ID of the release |

```bash
curl -s \
  -H "Accept: application/json" \
  -H "x-api-key: $S2_API_KEY" \
  "https://api.semanticscholar.org/datasets/v1/release/{release_id}/dataset/{dataset_name}"
```
