class anysync::node::install (
  Hash $githubartifact,
) {
  ensure_resources("githubartifact::install", $githubartifact)
}
