# @param githubartifact
#   Defines config for githubartifact
class anysync::pp::install (
  Hash $githubartifact,
) {
  ensure_resources("githubartifact::install", $githubartifact)
}
