class Queries{
  static String signup() {
    return """
        mutation Signup(\$input: SignupInput!) {
            signup(input: \$input) 
        }
    """;
  }
}