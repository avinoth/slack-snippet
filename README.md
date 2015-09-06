# slack-snippet

A slack slash command bot to save snippets/content quickly from slack.

### Getting started:-

1. Deploy the app to heroku and choose a url of your preference.
2. Next go to Configure Instructions page of your slack account and select `Slash Commands`
3. In the Add new slash command page, choose any command of  your choice though `/snippet` is preferred (since the tips are assumed with that command) and click `Add Slash Command Integration`
4. In the next page, in Integration Settings input the options as below,

  ```
    URL - The heroku url of your hosted app + `/gateway` eg: 'http://snippet.herokuapp.com/gateway`
    METHOD - GET
    DESCRIPTIVE LABEL - Enter a descriptive label of your choice for your team mates to recognize the integraion.
  ```
  
5. And, That's it. You're all set!


### Available Commands and Format:-

There are 5 commands available in total as of now. Their formats are,

##### new:-
    To create a new snippet. The syntax is `new-title-content`. Recommend avoiding '-' in title.
    eg: 
      cmd - /snippet new-heroku_pg_newBackup-heroku pg:backups --capture -a APP_NAME
      resp - Snippet saved successfully. You can access it by `/snippet get-heroku_pg_newBackup`.

##### get:-
    To get a existing snippet. They syntax is `get-title`.
    eg:
      cmd - /snippet get-heroku_pg_newBackup
      resp - heroku pg:backups --capture -a APP_NAME
      
##### edit:-
    To edit a existing snippet. The syntax is `edit-title-newContent`. Recommend avoiding '-' in title.
    eg: 
      cmd - /snippet edit-heroku_pg_newBackup-heroku pg:backups --capture
      resp - Snippet saved successfully. You can access it by `/snippet get-heroku_pg_newBackup`.

##### delete:-
    To destroy a existing snippet. The action is irreversible. The syntax is `delete-title`.
    eg:
      cmd - /snippet delete-heroku_pg_newBackup
      resp - Snippet is successfully destroyed. It is un-recoverable.

##### search:-
    To search for your snippets.
    syntax :- `search-query`
    eg:
      cmd - /snippet search-heroku
      resp - ```
              Your Search results:-
                1. heroku_pg_backup
                2. heroku db_migrate
            ```


### To Run it locally :-
1. Clone the repo `git clone https://github.com/avinoth/slack-snippet.git`
2. cd into slack-snippet.
3. run `bundle install`.
4. run `rake db:create && rake db:migrate`
5. run the app `ruby ./app.rb`
