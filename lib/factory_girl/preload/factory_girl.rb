if defined? FactoryGirl
  if FactoryGirl::VERSION =~ /^[4-9]|\d{2,}/
    FactoryGirl::SyntaxRunner.include(FactoryGirl::Preload::Helpers)
  else
    FactoryGirl::Proxy.include(FactoryGirl::Preload::Helpers)
  end
end
