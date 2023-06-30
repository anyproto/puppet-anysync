class anysync::consensusnode::install (
  Hash $githubartifact,
) {
  ensure_resources("githubartifact::install", $githubartifact)
}
