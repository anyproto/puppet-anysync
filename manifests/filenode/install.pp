# @param githubartifact
#   Defines config for githubartifact
class anysync::filenode::install (
  Hash $githubartifact,
) {
  ensure_resources("githubartifact::install", $githubartifact)
}
