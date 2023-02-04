class Queries {
  static String signup() {
    return """
        mutation Signup(\$input: SignupInput!) {
            signup(input: \$input) 
        }
    """;
  }

  static String getUsers() {
    return """ 
query FindPeople {
  findPeople {
    distance
    user {
      id
      name
      email
      profilePicture
      language
      createdAt
      updatedAt
    }
    chatUser {
      id
      socketId
      userId
      latitude
      longitude
    }
  }
}
    """;
  }
}
