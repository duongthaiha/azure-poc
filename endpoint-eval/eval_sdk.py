from pprint import pprint
import pandas as pd
from azure.identity import DefaultAzureCredential
import os
import pathlib
from application_endpoint import ApplicationEndpoint
from azure.ai.evaluation import evaluate
from azure.ai.evaluation import (
    ContentSafetyEvaluator,
    RelevanceEvaluator,
    CoherenceEvaluator,
    GroundednessEvaluator,
    FluencyEvaluator,
    SimilarityEvaluator,
)
from datetime import datetime
if __name__ == "__main__":
    azure_ai_project = {
        "subscription_id": os.environ["AZURE_SUBSCRIPTION_ID"],
        "resource_group_name": os.environ["AZURE_RESOURCE_GROUP"],
        "project_name": os.environ["AZUREAI_PROJECT_NAME"],
    }
    model_config = {
        "azure_endpoint": os.environ.get("AZURE_OPENAI_ENDPOINT"),
        "azure_deployment": os.environ.get("AZURE_OPENAI_DEPLOYMENT"),
    }

    content_safety_evaluator = ContentSafetyEvaluator(
        azure_ai_project=azure_ai_project, credential=DefaultAzureCredential()
    )
    relevance_evaluator = RelevanceEvaluator(model_config)
    coherence_evaluator = CoherenceEvaluator(model_config)
    groundedness_evaluator = GroundednessEvaluator(model_config)
    fluency_evaluator = FluencyEvaluator(model_config)
    similarity_evaluator = SimilarityEvaluator(model_config)

    path = str(pathlib.Path(pathlib.Path.cwd())) + "/evaluations/manual_input_data.jsonl"

    current_date = datetime.now().strftime("%Y-%m-%d")
    evaluation_name = f"Manual-Data-Eval-Run-{current_date}"

    results = evaluate(
        evaluation_name=evaluation_name,
        data=path,
        target=ApplicationEndpoint,
        evaluators={
            "content_safety": content_safety_evaluator,
            "coherence": coherence_evaluator,
            "relevance": relevance_evaluator,
            "groundedness": groundedness_evaluator,
            "fluency": fluency_evaluator,
            "similarity": similarity_evaluator,
        },
        azure_ai_project=azure_ai_project,
        evaluator_config={
            "content_safety": {"column_mapping": {"query": "${data.query}", "response": "${target.response}"}},
            "coherence": {"column_mapping": {"response": "${target.response}", "query": "${data.query}"}},
            "relevance": {
                "column_mapping": {"response": "${target.response}", "context": "${data.context}", "query": "${data.query}"}
            },
            "groundedness": {
                "column_mapping": {
                    "response": "${target.response}",
                    "context": "${data.context}",
                    "query": "${data.query}",
                }
            },
            "fluency": {
                "column_mapping": {"response": "${target.response}", "context": "${data.context}", "query": "${data.query}"}
            },
            "similarity": {
                "column_mapping": {"response": "${target.response}", "context": "${data.context}", "query": "${data.query}"}
            },
        },
        output_path="./prompt_eval_results.json"
    )