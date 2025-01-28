from flask import Flask, request, jsonify
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.ensemble import RandomForestClassifier
import numpy as np

# Initialize Flask app
app = Flask(__name__)

# Load and preprocess the data
data = pd.read_csv('data.csv')  # Make sure your CSV file is in the same directory as app.py
data = data.dropna(subset=['College'])
num_col = ['IELTS(9)', 'TOEFL(120)', 'PTE(90)']
for col in num_col:
    data[col] = data[col].fillna(data[col].mean())
data['Plustwo'] = data['Plustwo'].str.rstrip('%').astype(float)
data['Plustwo'] = data['Plustwo'].fillna(0)
cat_col = ['Country', 'Course', 'Internship&placement', 'Partime job', 'Stayback', 'Higher studies possible']
label_encoder = {col: LabelEncoder() for col in cat_col + ['College']}
for col, encoder in label_encoder.items():
    data[col] = encoder.fit_transform(data[col].astype(str))

# Define features and target
features = ['Country', 'Course', 'IELTS(9)', 'Plustwo', 'TOEFL(120)', 'PTE(90)', 'Internship&placement', 'Partime job', 'Stayback', 'Higher studies possible']
x = data[features]
y_college = data['College']
x_train, x_test, y_college_train, y_college_test = train_test_split(x, y_college, test_size=0.2, random_state=42)

# Initialize RandomForestClassifier
college_model = RandomForestClassifier(random_state=42, n_estimators=100)
college_model.fit(x_train, y_college_train)

# Define route for prediction
@app.route('/predict', methods=['POST'])
def predict():
    try:
        # Get data from the POST request
        data = request.get_json()

        # Extract the input features from the request data
        country = data['Country']
        course = data['Course']
        ielts = data['IELTS']
        plustwo = data['Plustwo']
        toefl = data['TOEFL']
        pte = data['PTE']
        internship = data['Internship']
        partime = data['Partime']
        stayback = data['Stayback']
        higher_studies = data['HigherStudies']

        # Prepare the user data
        user_data = pd.DataFrame({
            'Country': [label_encoder['Country'].transform([country])[0] if country in label_encoder['Country'].classes_ else -1],
            'Course': [label_encoder['Course'].transform([course])[0] if course in label_encoder['Course'].classes_ else -1],
            'IELTS(9)': [ielts],
            'Plustwo': [plustwo],
            'TOEFL(120)': [toefl],
            'PTE(90)': [pte],
            'Internship&placement': [label_encoder['Internship&placement'].transform([internship])[0] if internship in label_encoder['Internship&placement'].classes_ else -1],
            'Partime job': [label_encoder['Partime job'].transform([partime])[0] if partime in label_encoder['Partime job'].classes_ else -1],
            'Stayback': [label_encoder['Stayback'].transform([stayback])[0] if stayback in label_encoder['Stayback'].classes_ else -1],
            'Higher studies possible': [label_encoder['Higher studies possible'].transform([higher_studies])[0] if higher_studies in label_encoder['Higher studies possible'].classes_ else -1],
        })

        # Check for invalid input
        if user_data.isin([-1]).any().any():
            return jsonify({'error': 'Invalid input'}), 400

        # Make the prediction
        predicted_college = college_model.predict(user_data)
        college_name = label_encoder['College'].inverse_transform([predicted_college[0]])[0]

        # Return the predicted college
        return jsonify({'college': college_name})

    except Exception as e:
        # Return error if something goes wrong
        return jsonify({'error': str(e)}), 500

# Run the Flask app
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
