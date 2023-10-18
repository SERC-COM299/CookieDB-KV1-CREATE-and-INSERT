# CookieDB - Knowledge Verification Lab 1 - CREATE and INSERT

<img alt="points bar" align="right" height="36" src="../../blob/status/.github/activity-icons/points-bar.svg" />

In this lab, learners will write queries that create a database and a table in that database. Learners will then populate the table with data. Finally, learners will write queries to check the contents of the table.

## Scenario

"Cookie Co." is a supplier of various cookies to shops across the country. The company is in the process of creating a database to store information about their customers and orders. They want you to help them implement the database.

Below is a table of the different cookie types that Cookie Co. supplies.

| Cookie ID | Cookie Name                   | Price | Description                                              |
| --------- | ----------------------------- | ----- | -------------------------------------------------------- |
| 1         | Chocolate Chip                | 5.00  | Drop cookie featuring chocolate chips                    |
| 2         | Fortune Cookie                | 1.00  | Crisp and sugary cookie with a paper fortune inside      |
| 3         | Oatmeal Raisin                | 5.00  | Drop cookie made from oatmeal dough and raisins          |
| 4         | Snickerdoodle                 | 4.00  | Drop cookie made with butter and rolled in cinnamon      | 
| 5         | Sugar                         | 3.00  | Drop cookie made with sugar and vanilla                  |
| 6         | White Chocolate Macadamia Nut | 6.00  | Drop cookie made with white chocolate and macadamia nuts |

_Table 1: Products Table_

The main tasks in the lab are as follows:

1. Create a `Cookie` database.
2. Create a `Products` table.
3. Populate the `Products` table with data from _Table 1_.
4. Write a query that returns the contents of the `Products` table as is.
5. Write a query that returns the contents of the `Products` table in numerical order based on the price.

<!-- TODO insert where learners can find learning material needed for lab -->

When you push your changes back to the assignment GitHub repo, a grading action will run to assess if you have completed the exercises. You can push your changes back to GitHub at any time and check the 'Feedback' pull request (found in the 'Pull requests' tab) to review your progress. You can also use the 'Feedback' pull request to ask your lecturer to review your work or to ask for help if you get stuck.

## Exercise 1

1. Using the `11-Exercise1.sql` file, write a query that creates a database called `Cookie`.

2. Still using the `11-Exercise1.sql` file, add a query that creates a table in `Cookie` called `Products` with the following attributes:
   
   - cookieID
   - cookieName
   - description
   - price
   
   The attributes should take suitable value types.

3. Push your changes back to your assignment GitHub repo. Remember to try to make your commits atomic and your commit messages descriptive.

4. Wait a minute for the grading tests to run and then check the [Feedback pull request](../..pull/1) to see if you have completed the exercise successfully. When the grading action finishes, it will post a comment on the Feedback PR with a summary of how / if you have completed the exercise successfully.

Marks available: 38

## Exercise 2

1. Using the `12-Exercise2.sql` file, write a query that will populate the `Products` table with the data from *Table 1* above.

Marks available: 12

## Exercise 3

1. Using the `13-Exercise3.sql` file, write a query that will return the contents of the `Products` table as is.

2. Still using the `13-Exercise3.sql` file, write a query that returns the contents of the `Products` table in numerically order based on the cookie price (cheapest first).

Marks available: 25

## Post Exercises

- Commit any uncommitted queries and push your changes back to your assignment GitHub repo.
- Check the [Feedback pull request](../..pull/1) (found in the 'Pull requests' tab) on GitHub. When the grading action finishes, it will post a comment on the Feedback PR with a summary of how / if you have completed the exercises successfully.
- If there are any incomplete exercises, make changes to your queries, commit, and push the changes. The grading action will run again and post a new comment in the Feedback PR with updated results.
- You can also use the Feedback PR to ask your lecturer to review your attempt and to ask for help if you get stuck.

## Additional Learning Resources

-
