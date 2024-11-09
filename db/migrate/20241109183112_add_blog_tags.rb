class AddBlogTags < ActiveRecord::Migration[7.0]
  def change
    # Array of tag names for extended development topics
    tags = [
      # Core Development Languages
      "Ruby", "Python", "JavaScript", "Java", "C++", "C", "C#", "PHP", "Swift", "Kotlin",
      "TypeScript", "Go", "Rust", "Perl", "Scala", "Objective-C", "R", "MATLAB", "SAS",
      "Julia", "Haskell", "Elixir", "Dart", "Lua", "Shell Scripting", "Bash", "PowerShell",
      "Fortran", "COBOL", "Erlang", "Groovy",

      # Web Development
      "HTML", "CSS", "Sass", "Less", "Responsive Design", "Bootstrap", "Tailwind CSS",
      "Semantic UI", "Materialize CSS", "Bulma", "Foundation",

      # JavaScript Libraries and Frameworks
      "React", "Vue", "Angular", "Svelte", "jQuery", "Ember.js", "Backbone.js", "Next.js",
      "Nuxt.js", "Gatsby", "Express.js", "NestJS", "Redux", "RxJS", "GraphQL", "Apollo",

      # Back-end Frameworks
      "Ruby on Rails", "Django", "Flask", "Spring", "ASP.NET", "Laravel", "Symfony", "CodeIgniter",
      "CakePHP", "Phoenix", "Sinatra", "Koa.js", "FastAPI", "LoopBack", "Play Framework", "Zend Framework",
      "Hanami", "Grails",

      # Mobile Development
      "Android", "iOS", "React Native", "Flutter", "SwiftUI", "Xamarin", "Kotlin Multiplatform",
      "Apache Cordova", "Ionic", "Unity", "ARCore", "ARKit",

      # Databases and Query Languages
      "SQL", "NoSQL", "MySQL", "PostgreSQL", "SQLite", "MongoDB", "Redis", "Elasticsearch", "Cassandra",
      "Firebase", "Oracle", "MariaDB", "DynamoDB", "CouchDB", "Graph Databases", "Neo4j", "Realm",
      "Amazon Redshift", "BigQuery", "Athena", "Presto", "ClickHouse",

      # DevOps & Cloud Technologies
      "DevOps", "AWS", "Azure", "Google Cloud Platform", "Docker", "Kubernetes", "Ansible",
      "Terraform", "Jenkins", "CI/CD", "GitLab CI", "Bitbucket Pipelines", "CloudFormation",
      "Vagrant", "Puppet", "Chef", "Serverless", "Lambda", "FaaS", "OpenShift", "DigitalOcean",
      "Heroku", "Linode", "Vercel", "Netlify", "Cloudflare", "Istio", "OpenStack",

      # Data Science & Machine Learning
      "Machine Learning", "Data Science", "Artificial Intelligence", "Deep Learning",
      "NLP", "Computer Vision", "TensorFlow", "Keras", "PyTorch", "Scikit-Learn", "Pandas",
      "NumPy", "SciPy", "Matplotlib", "Seaborn", "Data Visualization", "Jupyter Notebook",
      "RStudio", "Google Colab", "MLflow", "AutoML", "Kubeflow", "Data Engineering",
      "Hadoop", "Spark", "Kafka", "Data Warehousing", "Data Lakes", "ETL", "Airflow", "Streamlit",

      # Security & Networking
      "Cybersecurity", "Cryptography", "Ethical Hacking", "Penetration Testing", "Network Security",
      "OAuth", "JWT", "SSO", "2FA", "SAML", "SSL/TLS", "VPN", "Firewalls", "IDS/IPS",
      "Nmap", "Wireshark", "Kali Linux", "Burp Suite", "OWASP", "ISO 27001", "SOC 2",
      "GDPR Compliance", "HIPAA Compliance",

      # Version Control & Collaboration
      "Git", "GitHub", "GitLab", "Bitbucket", "Version Control", "Collaboration Tools",
      "Confluence", "JIRA", "Trello", "Slack", "Zoom", "Microsoft Teams", "Asana",

      # Software Testing & Quality Assurance
      "Testing", "TDD", "BDD", "Unit Testing", "Integration Testing", "End-to-End Testing",
      "Jest", "Mocha", "Chai", "RSpec", "JUnit", "Selenium", "Cucumber", "Cypress", "Postman",
      "Load Testing", "Performance Testing", "Penetration Testing", "QUnit", "Protractor",

      # Other Technologies & Topics
      "Blockchain", "Cryptocurrency", "NFT", "DeFi", "Smart Contracts", "Solidity",
      "Ethereum", "Bitcoin", "Polkadot", "Chainlink", "Decentralized Apps", "Web3",
      "IoT", "Embedded Systems", "Hardware Programming", "Arduino", "Raspberry Pi",
      "3D Printing", "Wearable Tech", "Edge Computing", "Quantum Computing",

      # Software Development Methodologies
      "Agile", "Scrum", "Kanban", "Lean", "Waterfall", "XP", "DevOps Culture",
      "Pair Programming", "Continuous Delivery", "Continuous Deployment", "Version Control",

      # Miscellaneous
      "Code Quality", "Documentation", "APIs", "SDKs", "Command Line", "CLIs",
      "WebAssembly", "Progressive Web Apps", "SEO for Developers", "Digital Marketing",
      "Technical Writing", "Open Source", "Freelancing", "Remote Work", "Career Development",
      "Software Architecture", "Microservices", "Monolithic Architecture", "Serverless Architecture",
      "Event-Driven Architecture", "RESTful APIs", "GraphQL APIs", "gRPC", "Data Privacy", "Ethics in AI",

      # Medical and Health Sciences
      "Cardiology", "Neurology", "Oncology", "Orthopedics", "Pediatrics", "Psychiatry",
      "Surgery", "Dermatology", "Radiology", "Gynecology", "Endocrinology", "Gastroenterology",
      "Ophthalmology", "Urology", "Public Health", "Epidemiology", "Clinical Trials", "Genomics",
      "Immunology", "Telemedicine", "EHR Systems", "Wearable Health Tech", "Biomedical Devices",
      "Mental Health", "Nutrition", "Substance Abuse Prevention",

      # Finance and Economics
      "Accounting", "Auditing", "Financial Analysis", "Risk Management", "Corporate Finance",
      "Taxation", "Investment Banking", "Wealth Management", "Budgeting", "Microeconomics",
      "Macroeconomics", "Behavioral Economics", "Game Theory", "Cryptocurrency", "Blockchain",
      "Stock Market", "Forex", "Bonds", "Real Estate Investment", "Portfolio Management",
      "Financial Planning",

      # Engineering and Robotics
      "Mechanical Engineering", "Electrical Engineering", "Civil Engineering", "Aerospace Engineering",
      "Automotive Engineering", "Biomedical Engineering", "Chemical Engineering", "Structural Engineering",
      "Robotics", "Automation", "Control Systems", "Mechatronics", "Industrial Design",
      "Manufacturing Engineering", "CAD", "CAM", "3D Printing", "Drones", "Sensors", "Prototyping",

      # Environmental Sciences
      "Ecology", "Environmental Science", "Climate Change", "Sustainability", "Renewable Energy",
      "Environmental Policy", "Conservation", "Oceanography", "Forestry", "Agriculture",
      "Water Management", "Waste Management", "Pollution Control", "Environmental Engineering",
      "Biodiversity", "Wildlife Protection", "Carbon Footprint", "Green Building", "Environmental Law",

      # Humanities and Social Sciences
      "History", "Philosophy", "Sociology", "Anthropology", "Psychology", "Political Science",
      "International Relations", "Archaeology", "Linguistics", "Gender Studies", "Cultural Studies",
      "Ethics", "Art History", "Religious Studies", "Economics", "Education", "Law",
      "Media Studies", "Human Geography", "Social Work", "Public Policy",

      # Business and Management
      "Marketing", "Sales", "Operations Management", "Project Management", "Human Resources",
      "Entrepreneurship", "Business Strategy", "Supply Chain Management", "Leadership",
      "Change Management", "Customer Service", "Business Ethics", "Corporate Communications",
      "Risk Management", "Brand Management", "Public Relations", "Business Analytics",
      "E-commerce", "Digital Marketing", "Agile Project Management",

      # Mathematics and Statistics
      "Calculus", "Algebra", "Geometry", "Statistics", "Probability", "Linear Algebra",
      "Mathematical Modeling", "Number Theory", "Discrete Mathematics", "Set Theory",
      "Combinatorics", "Optimization", "Game Theory", "Graph Theory", "Differential Equations",
      "Dynamical Systems", "Bayesian Analysis", "Data Analysis", "Stochastic Processes",

      # Physics and Astronomy
      "Quantum Mechanics", "Classical Mechanics", "Thermodynamics", "Electromagnetism",
      "Optics", "Astrophysics", "Cosmology", "Particle Physics", "Relativity",
      "Condensed Matter Physics", "Nuclear Physics", "Space Exploration", "Astronomy",
      "Planetary Science", "Gravitational Waves", "Black Holes", "Dark Matter",
      "Experimental Physics", "Theoretical Physics", "Astrobiology",

      # Arts and Media
      "Visual Arts", "Painting", "Sculpture", "Photography", "Graphic Design",
      "Digital Art", "Film Production", "Animation", "Video Editing", "Cinematography",
      "Music Theory", "Music Production", "Sound Engineering", "Creative Writing",
      "Poetry", "Screenwriting", "Theater", "Dance", "Literature", "Art Criticism",

      # Other Fields and Interdisciplinary Topics
      "Quantum Computing", "Ethics in AI", "Human-Computer Interaction", "Game Development",
      "UX/UI Design", "Information Theory", "Virtual Reality", "Augmented Reality",
      "Data Ethics", "Cognitive Science", "Sociotechnical Systems", "Systems Thinking",
      "Futurism", "Sustainability Studies", "Climate Adaptation", "Public Health Policy",
      "Cross-Cultural Communication", "Digital Humanities", "Urban Planning"
    ]

    # Create each tag in the BlogApp::Tag model
    tags.each do |tag_name|
      BlogApp::Tag.find_or_create_by(name: tag_name)
    end
  end
end
