<?php
$conn = new mysqli("localhost","root","","condb");

$result = $conn->query("SELECT * FROM users");

$data = array();
while($row = $result->fetch_assoc()){
    $data[] = $row;
}

echo json_encode($data);
?>
