Then /^the build directory should exist/ do
  in_current_dir { Dir["build/**/*"].should_not be_empty }
end