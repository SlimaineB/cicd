variables {
  input = "test"
}

run "input_and_output_match" {

  assert {
    condition     = output.returned.example == "test"
    error_message = "The output does not match the input."
  }
}
