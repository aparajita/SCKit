<?php
    header("Content-Type: text/plain");

    $action = $_GET["action"];

    if ($action == "echo")
        echo $_GET["text"];
    elseif ($action == "modify")
        echo '"' . $_GET["text"] . '"' . " to you, too!";
    elseif ($action == "reverse")
        echo strrev($_GET["text"]);
?>
