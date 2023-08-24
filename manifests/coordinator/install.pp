class anysync::coordinator::install (
  Hash $githubartifact,
) {
  ensure_resources("githubartifact::install", $githubartifact)
}
