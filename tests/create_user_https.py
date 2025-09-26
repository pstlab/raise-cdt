import sys
import requests
import warnings
from urllib3.exceptions import InsecureRequestWarning
from faker import Faker
import logging

# Suppress InsecureRequestWarning from urllib3
warnings.filterwarnings('ignore', category=InsecureRequestWarning)

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)

handler = logging.StreamHandler(sys.stdout)
handler.setLevel(logging.DEBUG)
logger.addHandler(handler)

fake = Faker('it_IT')

if __name__ == '__main__':
    url = sys.argv[1] if len(sys.argv) > 1 else 'https://localhost:8443'
    session = requests.Session()

    login_response = session.post(
        url + '/login', json={'username': 'admin', 'password': 'admin'}, verify=False)
    if login_response.status_code != 200:
        logger.error(login_response.json())
        sys.exit(1)
    token = login_response.json()['token']

    first_name = fake.first_name()
    response = session.post(url + '/raise-users', headers={'Authorization': 'Bearer ' + token}, json={
        'google_id': first_name.lower() + str(fake.random_number(digits=5, fix_len=True))}, verify=False)
    if response.status_code != 201:
        logger.error('Failed to create user')
        sys.exit(1)
    user_uid = response.text
    logger.info(f'Created user {first_name} with uid {user_uid}')

    response = session.patch(url + f'/items/{user_uid}', headers={'Authorization': 'Bearer ' + token}, json={
        'properties': {
            'name': first_name,
            'baseline_nutrition': True,  # Assume user has baseline nutrition
            'baseline_fall': 2,  # Example: low fall risk
            'baseline_freezing': 1,  # Example: rare freezing
            'baseline_heart_rate': 72,  # Typical resting heart rate
            'state_anxiety_presence': 0,  # No anxiety present
            'baseline_blood_pressure': 120,  # Normal blood pressure
            'sensory_profile': False,  # No sensory profile issues
            'stress': 3,  # Mild stress
            'psychiatric_disorders': False,  # No psychiatric disorders
            'parkinson': True,  # User has Parkinson's
            'older_adults': False,  # Not an older adult
            'psychiatric_patients': False,  # Not a psychiatric patient
            'multiple_sclerosis': False,  # No MS
            'young_pci_autism': False  # No autism
        }}, verify=False)
    if response.status_code != 204:
        logger.error('Failed to set user properties')
        sys.exit(1)
    logger.info(f'Set properties for user {user_uid}')

    response = session.post(url + f'/data/{user_uid}', headers={'Authorization': 'Bearer ' + token}, json={
        'crowding': 0,
        'altered_nutrition': False,
        'altered_thirst_perception': 0,
        'bar_restaurant': False,
        'architectural_barriers': False,
        'water_balance': 0,
        'sleep_duration_quality': 5,
        'water_fountains': False,
        'recent_freezing_episodes': 0,
        'heart_rate': 72,
        'heart_rate_differential': 0,
        'public_events_frequency': False,
        'respiratory_rate': 16,
        'galvanic_skin_response': 0,
        'lighting': True,
        'noise_pollution': 50,
        'user_reported_noise_pollution': 0,
        'air_pollution': 30,
        'traffic_levels': 20,
        'lack_of_ventilation': 2,
        'path_slope': False,
        'safety_perception': True,
        'rough_path': False,
        'public_events_presence': False,
        'high_blood_pressure': 120,
        'low_blood_pressure': 80,
        'social_pressure': False,
        'sittings': False,
        'self_perception': True,
        'restroom_availability': True,
        'sweating': 3,
        'ambient_temperature': 22.5,
        'body_temperature': 36.5,
        'ambient_humidity': 45,
        'excessive_urbanization': False,
        'green_spaces': True
    }, verify=False)
    if response.status_code != 204:
        logger.error('Failed to add data entry')
        sys.exit(1)
    logger.info(f'Added data entry for user {user_uid}')
