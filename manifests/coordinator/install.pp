# @param githubartifact
#   Defines config for githubartifact
class anysync::coordinator::install (
  Hash $githubartifact,
) {
  ensure_resources("githubartifact::install", $githubartifact)
}
