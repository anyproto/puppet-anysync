# @param githubartifact
#   Defines config for githubartifact
class anysync::node::install (
  Hash $githubartifact,
) {
  ensure_resources("githubartifact::install", $githubartifact)
}
