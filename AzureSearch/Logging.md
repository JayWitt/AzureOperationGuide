# Azure Cognitive Search -- Monitoring



|What to Monitor|Source|Metric|Alert Trigger|Reaction|
|----|-----|---|---|--|
|Identify Long-Running Queries|Log Analytics|AzureDiagnostics|Table	DurationMs > x|
|Search Queries per Second|Azure Monitor|Search Queries per Second|	
|Indexer Status|Portal|
|Search Traffic Analytics|Application Insights|
|Correlate query request with indexing operations, and render the data points across a time chart|Log Analytics|AzureDiagnostics	
