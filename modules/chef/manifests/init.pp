class chef {
  class {'chef::install': } ->
  class {'chef::config': }
}
