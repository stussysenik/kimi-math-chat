use magnus::{function, prelude::*, Error, Ruby};
use serde::Serialize;

#[derive(Serialize)]
struct WolframResult {
    success: bool,
    pods: Option<Vec<Pod>>,
    error: Option<String>,
}

#[derive(Serialize)]
struct Pod {
    id: String,
    title: String,
    subpods: Vec<SubPod>,
}

#[derive(Serialize)]
struct SubPod {
    plaintext: Option<String>,
}

fn query(app_id: String, expression: String) -> Result<String, Error> {
    let url = format!(
        "https://api.wolframalpha.com/v2/query?input={}&appid={}&output=json&format=plaintext",
        url::form_urlencoded::byte_serialize(expression.as_bytes()).collect::<String>(),
        url::form_urlencoded::byte_serialize(app_id.as_bytes()).collect::<String>()
    );

    let response = reqwest::blocking::get(&url).map_err(|e| {
        Error::new(
            magnus::exception::runtime_error(),
            format!("HTTP request failed: {e}"),
        )
    })?;

    let body: serde_json::Value = response.json().map_err(|e| {
        Error::new(
            magnus::exception::runtime_error(),
            format!("JSON parse failed: {e}"),
        )
    })?;

    let query_result = &body["queryresult"];
    let success = query_result["success"].as_bool().unwrap_or(false);

    if !success {
        let result = WolframResult {
            success: false,
            pods: None,
            error: Some("Wolfram Alpha could not interpret the query".into()),
        };
        return serde_json::to_string(&result).map_err(|e| {
            Error::new(
                magnus::exception::runtime_error(),
                format!("Serialization failed: {e}"),
            )
        });
    }

    let pods: Vec<Pod> = query_result["pods"]
        .as_array()
        .unwrap_or(&vec![])
        .iter()
        .map(|p| Pod {
            id: p["id"].as_str().unwrap_or("").to_string(),
            title: p["title"].as_str().unwrap_or("").to_string(),
            subpods: p["subpods"]
                .as_array()
                .unwrap_or(&vec![])
                .iter()
                .map(|sp| SubPod {
                    plaintext: sp["plaintext"].as_str().map(|s| s.to_string()),
                })
                .collect(),
        })
        .collect();

    let result = WolframResult {
        success: true,
        pods: Some(pods),
        error: None,
    };

    serde_json::to_string(&result).map_err(|e| {
        Error::new(
            magnus::exception::runtime_error(),
            format!("Serialization failed: {e}"),
        )
    })
}

#[magnus::init]
fn init(ruby: &Ruby) -> Result<(), Error> {
    let module = ruby.define_module("WolframExt")?;
    module.define_singleton_method("query", function!(query, 2))?;
    Ok(())
}
