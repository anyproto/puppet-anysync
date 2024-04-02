# @param githubartifact
#   Defines config for githubartifact
class anysync::ns::install (
  Hash $githubartifact,
) {
  ensure_resources("githubartifact::install", $githubartifact)
}
