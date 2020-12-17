Problem Statement:
The total number of cyber attacks have been increasing through SMS and emails. hence we have generated a model that helps in detecting this problem and finding the best solution. 
The papers that we refered have used some machine learning alogorithms as we have refered to 3 papers to build our models we have compared the best accuracy of the model rom the papers with ours.
The maximum accuracy that they have acheived is 95% in one model and all other models accuracy range from 85-92%.

Solution:
-we have used data pre=processing techniques such as stopword removal, stemming the words, finding out the parts of speech for each Ham words and spam words seperately, 
 converting the Lables column to numeric. 
-converting the text into numeric by using two vectores. 
 In the papers that we have refred everyone has either used TF-IDF vectorizer or Count Vectorizer, but we have used both vectorizers in order to compaer the results as generally TF-IDF vectorizer gives better results 
 when compared to count vectorizer. 
-In the refered papers they have used maily Naive Bayes and Svm models in order to predict the messages if they are ham or spam. But we have used 4 machine learnng models:
	
	SVM
	RandomForest
	Navie Bayes
	Logistic Regression

-We have found out that while performing the models we have acheived 3 % more accuracy than the hihest accuracy that was acheived in the refered papers and average accuracy of all our models is 5 % more than what they have acheived.
-We have even additionally added a feature of creating an local server appliaction that allows the user to predict if the message they have recived is spam or not.

-We feel we have succeeded in getting better accuracies that was our main goal of the project as we wanted the model to predict correct results for spam and ham messages. The most important thing is to attain an avg accuracy 
of all models because it gives a clear indication that the pre-processing techinques that we have used gives us good results.




Running the Code file:

- In the zipped folder you can find the follwing data:
	
	Static folder
	templates folder
	Pickle folder
	Procfile
	Project.ipynb
	Requirements.txt
	README.txt
	
- Static folder consists of the css file that we have used.
- Templates folder consists of the home page and results page html file.
- Pickle folder consists of the application that we have built with both pickle files and appy.py file.
- Please run the code by uploading the all the files in anaconda for avoiding errors.
- You can find the complete code in Project.ipynb file.
- After running the complete file in anaconda. Please use the pickle files that is provided in the zip file.
- Go to the Anaconda command prompt and be in the Pickle folder where we have provided both pickle files and the app.py file then just type "flask run". ((base) E:\Studies\SEM 3 FALL 2020\AIT 590\Project\Pickle>flask run)
- You can see a server address that would be found after running flask. " * Running on http://127.0.0.1:5000/ (Press CTRL+C to quit)"
- Please copy paste the link in any browser and you can see the home page of the application appearing.
- Please tyoe any message that you have recieved in you cell phone and you think it might be spam and click on predict button.
- After clicking on the the predict you can see the results page where yu can find the output saying Spam message or Ham message.
- You can just click on the back button in order to use the application again. Close the browser if you want to exit.



 