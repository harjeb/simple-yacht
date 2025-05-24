# Product Context

This file provides a high-level overview of the project and the expected product that will be created. Initially it is based upon projectBrief.md (if provided) and all other available project-related information in the working directory. This file is intended to be updated as the project evolves, and should be used to inform all other modes of the project's goals and context.
2025-05-23 02:56:19 - Log of updates made will be appended as footnotes to the end of this file.

*

## Project Goal

* Create a networked Yahtzee-style game.

## Key Features

*   **Game Modes:**
    *   Single-player mode.
    *   Two-player mode.
*   **Scoring & Ranking:**
    *   Standard Yahtzee scoring rules.
    *   High score leaderboards:
        *   Personal best scores.
        *   Global high scores.
        *   Detailed local leaderboard: Stores and displays the top 10 personal scores with usernames.
*   **Gameplay Features:**
    *   Dice rolling animation on reset/roll.
*   **User Identification:**
    *   Mandatory username setup on first application launch for personalization and leaderboard display.
*   **Two-Player Mode Details:**
    *   Random matchmaking.
    *   Friend battle mode.
*   **Random Matchmaking Features:**
    *   ELO rating system.
    *   Global ladder ranking based on ELO.
    *   Scores from random matches contribute to ELO and ladder.
*   **Friend Battle Mode Details:**
    *   Scores from friend battles do *not* affect ELO or ladder ranking.
*   **Networking:**
    *   Network capabilities for 2-player modes and global leaderboards.
*   **Removed Features:**
    *   Third-party login functionality has been explicitly removed from the project scope to simplify user authentication.

## Overall Architecture

* Flutter application.
* Backend for networking features (matchmaking, leaderboards, ELO).