# Multi Magic

**Multi Magic** is a comprehensive application suite designed to manage various aspects of personal and professional life. Built with a Ruby on Rails backend and a Vue.js frontend, the application encompasses the following modules:

- **Notes**: A simple and intuitive note-taking application.
- **Blog**: A platform to write, edit, and publish blog posts.
- **Contact**: An address book to manage personal and professional contacts.
- **Finances**: A tool to track income, expenses, and manage budgets.
- **Password Manager**: A secure vault to store and manage passwords.

## Features

- **Modular Architecture**: Each module operates independently, allowing for easy maintenance and scalability.
- **Dockerized Environment**: The entire application runs within Docker containers, ensuring consistency across different environments.
- **Modern Frontend**: Utilizes Vue.js to provide a responsive and dynamic user interface.
- **Secure Backend**: Built with Ruby on Rails, ensuring robust data handling and security.

## Prerequisites

Before setting up the project, ensure you have the following installed:

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Installation

1. **Clone the Repository**:

   ```bash
   git clone https://github.com/Hama99o/multi_magic.git
   cd multi_magic
   ```

2. **Environment Configuration**:

   Duplicate the `.env.example` file and rename the copy to `.env`. Update the environment variables in the `.env` file as needed.

3. **Build and Start the Application**:

   ```bash
   docker-compose up --build
   ```

   This command will build the Docker images and start the containers for the application.

4. **Access the Application**:

   Once the containers are up and running, the application can be accessed at `http://localhost:3000`.

## Usage

- **Notes**: Navigate to the 'Notes' section to create, edit, and delete notes.
- **Blog**: In the 'Blog' section, you can write new posts, edit existing ones, and manage your publications.
- **Contact**: Use the 'Contact' module to add, edit, and manage your contacts.
- **Finances**: Track your income and expenses in the 'Finances' section.
- **Password Manager**: Store and manage your passwords securely in the 'Password Manager' module.

## Contributing

We welcome contributions to enhance the functionality and features of Multi Magic. To contribute:

1. Fork the repository.
2. Create a new branch: `git checkout -b feature/YourFeatureName`.
3. Make your changes and commit them: `git commit -m 'Add some feature'`.
4. Push to the branch: `git push origin feature/YourFeatureName`.
5. Open a pull request.

Please ensure your code adheres to the project's coding standards and includes appropriate tests.

## Acknowledgements

We appreciate the open-source community for the tools and frameworks that made this project possible.

