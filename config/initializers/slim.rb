Slim::Embedded.options[:markdown] = { :smartypants => true }

Slim::Engine.set_options({
  pretty: Rails.env.development?, 
  sort_attrs: false,
  format: :html,
  tabsize: 2
})