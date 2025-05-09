# Maven AI Abodo Feed

A Rails application that imports and displays property data from an XML feed. The application specifically filters properties located in Madison, WI, calculates the total number of bedrooms, and stores the data in a database.

## Features

- XML data import from Abodo feed
- Property filtering by location (Madison, WI)
- Docker containerization for easy setup and deployment
- CRUD operations for property management
- RESTful API endpoints for property data

## Tech Stack

- Ruby version: 3.2.2
- Rails version: 7.1.5
- Database: PostgreSQL 14
- Docker
- Docker Compose
- Tailwind CSS for styling (via CDN)
- Nokogiri for XML parsing

## Getting Started

### Prerequisites

- [Docker](https://docs.docker.com/engine/install/)
- [Docker Compose](https://docs.docker.com/compose/install/)

### Setup Instructions

1. Clone the repository

   ```bash
   git clone https://github.com/paetinspier/Maven-Abodo-Feed.git
   cd Maven-Abodo-Feed
   ```

2. Create a `.env` file in the project root with the following content:

   ```
   POSTGRES_USER=postgres
   POSTGRES_PASSWORD=password123
   POSTGRES_DB=abdo_feed_development
   DATABASE_HOST=db
   DATABASE_USERNAME=postgres
   DATABASE_PASSWORD=password123
   ```

3. Build and start the Docker containers

   ```bash
   docker-compose up --build
   ```

   This will:

   - Build the Docker images
   - Start the PostgreSQL database
   - Run database migrations
   - Import property data from the XML feed via rake command
   - Start the Rails server on port 3000

4. Access the application

   Open your browser and navigate to http://localhost:3000/properties

### Docker Commands

```bash
# Build and start containers in the foreground
docker-compose up

# Build and start containers in the background
docker-compose up -d

# Stop containers
docker-compose down

# View logs
docker-compose logs

# Access Rails console
docker-compose exec web rails console

# Run database migrations
docker-compose exec web rails db:migrate
```

## Development

### Running Tests

```bash
# Run all tests
docker-compose exec web rails test
```

Test files, including those for the XML import logic (located in test/services/property_importer_test.rb), ensure that the property import service behaves correctly under various scenarios.

### Important Rake Tasks

```bash
# Import properties from XML feed
docker-compose exec web rails property:import

# Reset database and reimport properties
docker-compose exec web rails db:reset property:import
```

## Data Import Process

The application imports property data from an XML file located at db/data/sample_abodo_feed.xml using a dedicated service file. The import process:

1. Parses the XML using Nokogiri.
2. Filters properties by location (Madison, WI).
3. Calculates the total number of bedrooms for each property.
4. Creates or updates property records in the database.

The import logic is encapsulated in the service file app/services/property_importer.rb, which is called by both the Rake task and the background job.

To manually trigger the import rake:

```bash
docker-compose exec web rails property:import
```

## Additional Information

This application was developed as part of Maven AI's assessment process. It demonstrates skills in Rails development, data processing, Docker containerization, Tailwind CSS integration, and test-driven development.
