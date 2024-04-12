import requests
from bs4 import BeautifulSoup
import csv
import json
 
def scrape_job_postings(url):
    # Send a GET request to the URL
    response = requests.get(url)
    # Check if the request was successful
    if response.status_code == 200:
        # Parse the HTML content
        soup = BeautifulSoup(response.text, 'html.parser')
        # Find all job postings on the page
        job_postings = soup.find_all('div', class_='job-posting')
        # List to store extracted job data
        extracted_jobs = []
        # Extract job details from each posting
        for posting in job_postings:
            job_title = posting.find('h2', class_='job-title').text.strip()
            company_name = posting.find('p', class_='company-name').text.strip()
            location = posting.find('p', class_='location').text.strip()
            posting_date = posting.find('p', class_='posting-date').text.strip()
            # Store job data in a dictionary
            job_data = {
                'Job Title': job_title,
                'Company Name': company_name,
                'Location': location,
                'Posting Date': posting_date
            }
            # Append job data to the list
            extracted_jobs.append(job_data)
        return extracted_jobs
    else:
        print("Failed to retrieve data from the URL.")
        return None
 
def save_to_csv(data, filename):
    with open(filename, 'w', newline='', encoding='utf-8') as file:
        writer = csv.DictWriter(file, fieldnames=data[0].keys())
        writer.writeheader()
        writer.writerows(data)
    print(f"Data saved to {filename}")
 
def save_to_json(data, filename):
    with open(filename, 'w', encoding='utf-8') as file:
        json.dump(data, file, indent=4)
    print(f"Data saved to {filename}")
 
if __name__ == "__main__":
    # URL of the website to scrape
    url = 'https://www.naukri.com/recruit/job-posting'
    # Scrape job postings
    job_data = scrape_job_postings(url)
    if job_data:
        # Save extracted data to CSV
        save_to_csv(job_data, 'job_postings.csv')
        # Save extracted data to JSON
        save_to_json(job_data, 'job_postings.json')
