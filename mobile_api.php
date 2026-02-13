<?php
// =================================================================================
// L MOBILE APP API

// =================================================================================
// INSTRUCTIONS FOR AGENCY:
// 1. Edit the 'DATABASE CONFIGURATION' section below to match your local DB.
// 2. Edit the 'RESOURCE MAPPING' section to map API endpoints to your Tables.
// 3. Upload this file to your website root (e.g., public_html/mobile_api.php).
// =================================================================================

// --- 1. SECURITY & CONFIGURATION -----------------------------------------------

// SECURITY: Change this to a strong random string!
$API_SECRET_KEY = "ThIsCoD3HeLpsT0cOnNeCtW1ThM0b!l34pPr";

// DATABASE CONFIGURATION
$DB_HOST = "localhost";
$DB_USER = "YOUR_DB_USER";     // <-- UPDATE THIS
$DB_PASS = "YOUR_DB_PASSWORD"; // <-- UPDATE THIS
$DB_NAME = "YOUR_DB_NAME";     // <-- UPDATE THIS

// --- 2. RESOURCE MAPPING (THE "FUTURE PROOF" PART) ------------------------------
// usage: 'api_action_name' => ['table' => 'actual_table_name', 'default_sort' => 'id DESC']
// You can Expose ANY new table just by adding a line here.

$RESOURCES = [
    // Content Modules
    // 'methods' defines allowed CRUD operations: 'list' (Read), 'create', 'update', 'delete'
    'news'          => ['table' => 'news_table',         'select' => '*', 'sort' => 'id DESC', 'methods' => ['list']], 
    'banners'       => ['table' => 'banner_table',       'select' => 'id, title, image_path', 'sort' => 'id ASC', 'methods' => ['list']],
    'gallery'       => ['table' => 'photo_gallery',      'select' => '*', 'sort' => 'id DESC', 'methods' => ['list']],
    'videos'        => ['table' => 'video_gallery',      'select' => '*', 'sort' => 'id DESC', 'methods' => ['list']],
    'downloads'     => ['table' => 'study_materials',    'select' => '*', 'sort' => 'id DESC', 'methods' => ['list']],
    'courses'       => ['table' => 'course_details',     'select' => 'id, course_name, fee, duration, image', 'sort' => 'sort_order ASC', 'methods' => ['list']],
    'staff'         => ['table' => 'employee_table',     'select' => 'id, name, designation, phone, photo', 'sort' => 'id ASC', 'methods' => ['list']],
    'pages'         => ['table' => 'cms_pages',          'select' => 'id, page_title, content', 'sort' => 'id ASC', 'methods' => ['list']],
    
    // Academic Data (Sensitive constraints handled in logic)
    'admit_cards'   => ['table' => 'admit_card_table',   'select' => '*', 'sort' => 'id DESC', 'methods' => ['list']],
    'fee_history'   => ['table' => 'collected_fees',     'select' => '*', 'sort' => 'payment_date DESC', 'methods' => ['list']],
    'dues_list'     => ['table' => 'student_dues',       'select' => '*', 'sort' => 'id ASC', 'methods' => ['list']],
    'results'       => ['table' => 'online_exam_result', 'select' => '*', 'sort' => 'exam_date DESC', 'methods' => ['list']],
    
    // Example: To enable data entry from App (e.g., Submit Inquiry)
    // 'inquiries' => ['table' => 'contact_form', 'select' => '*', 'methods' => ['create', 'list']],
];

// =================================================================================
// 🚫 STOP EDITING BELOW THIS LINE UNLESS YOU ARE A DEVELOPER
// =================================================================================

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');

// 1. Authenticate
if (!isset($_GET['api_key']) || $_GET['api_key'] !== $API_SECRET_KEY) {
    http_response_code(403);
    echo json_encode(["status" => "error", "message" => "Invalid API Key"]);
    exit;
}

// 2. Connect DB
$conn = new mysqli($DB_HOST, $DB_USER, $DB_PASS, $DB_NAME);
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Database Connection Failed: " . $conn->connect_error]);
    exit;
}
$conn->set_charset("utf8mb4");

// 3. Router
$action = isset($_GET['action']) ? $_GET['action'] : '';

switch ($action) {
    case 'ping':
        echo json_encode(["status" => "success", "message" => "Server is reachable", "time" => time()]);
        break;

    // --- GENERIC RESOURCE HANDLER (CRUD) ---
    // Usage: ?action=list&resource=news (READ)
    // Usage: ?action=create&resource=news (CREATE - POST data)
    // Usage: ?action=update&resource=news&id=1 (UPDATE - POST data)
    // Usage: ?action=delete&resource=news&id=1 (DELETE)
    case 'list':
    case 'create':
    case 'update':
    case 'delete':
        handleCrudResource($conn, $RESOURCES, $action);
        break;

    // --- SPECIFIC MODULES ---
    case 'login':
        // CONFIG: Map this to your Student Login table
        $loginTable = isset($RESOURCES['student_login']) ? $RESOURCES['student_login']['table'] : 'students';
        $userCol    = 'reg_no';  // Column for Username/ID
        $passCol    = 'password'; // Column for Password
        
        $data = getJsonInput();
        $username = isset($data['username']) ? $conn->real_escape_string($data['username']) : '';
        $password = isset($data['password']) ? $data['password'] : '';
        
        if(!$username || !$password) {
            echo json_encode(["status" => "error", "message" => "Missing username or password"]);
            break;
        }

        $sql = "SELECT * FROM `$loginTable` WHERE `$userCol` = '$username' LIMIT 1";
        $result = $conn->query($sql);

        if($result && $result->num_rows > 0) {
            $user = $result->fetch_assoc();
            $dbPass = $user[$passCol];
            $authSuccess = false;

            if (password_verify($password, $dbPass)) $authSuccess = true;
            elseif ($dbPass === $password) $authSuccess = true;
            elseif ($dbPass === md5($password)) $authSuccess = true;

            if ($authSuccess) {
                unset($user[$passCol]); 
                echo json_encode(["status" => "success", "message" => "Login Successful", "data" => $user]);
            } else {
                echo json_encode(["status" => "error", "message" => "Invalid Password"]);
            }
        } else {
            echo json_encode(["status" => "error", "message" => "User not found"]);
        }
        break;
        
    case 'profile':
        if(isset($_GET['reg_no'])) {
            $reg = $conn->real_escape_string($_GET['reg_no']);
            $sql = "SELECT * FROM students WHERE reg_no = '$reg' LIMIT 1"; 
            $res = $conn->query($sql);
            if($res && $res->num_rows > 0) {
                echo json_encode(["status" => "success", "data" => $res->fetch_assoc()]);
            } else {
                echo json_encode(["status" => "error", "message" => "Student not found"]);
            }
        } else {
            echo json_encode(["status" => "error", "message" => "Missing reg_no"]);
        }
        break;

    default:
        echo json_encode(["status" => "error", "message" => "Unknown Action: $action"]);
        break;
}

$conn->close();

// =================================================================================
// 🛠️ HELPER FUNCTIONS
// =================================================================================

function getJsonInput() {
    $data = json_decode(file_get_contents('php://input'), true);
    return is_array($data) ? $data : $_GET;
}

function handleCrudResource($conn, $map, $action) {
    $resource = isset($_GET['resource']) ? $_GET['resource'] : '';
    
    if (!array_key_exists($resource, $map)) {
        echo json_encode(["status" => "error", "message" => "Resource not found"]);
        return;
    }

    $config = $map[$resource];
    $table = $config['table'];
    
    // Check Permissions (Default to READ ONLY if not set)
    $allowedMethods = isset($config['methods']) ? $config['methods'] : ['list'];
    if (!in_array($action, $allowedMethods)) {
        echo json_encode(["status" => "error", "message" => "Action '$action' not allowed for this resource"]);
        return;
    }

    // --- READ (LIST) ---
    if ($action === 'list') {
        $columns = isset($config['select']) ? $config['select'] : '*';
        $orderBy = isset($config['sort']) ? $config['sort'] : 'id DESC';
        $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
        $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 20;
        $offset = ($page - 1) * $limit;

        // Filters
        $whereClauses = ["1=1"];
        foreach ($_GET as $key => $val) {
            if (strpos($key, 'filter_') === 0) {
                $colName = preg_replace("/[^a-zA-Z0-9_]/", "", substr($key, 7)); 
                $safeVal = $conn->real_escape_string($val);
                $whereClauses[] = "`$colName` = '$safeVal'";
            }
        }
        $whereSql = implode(' AND ', $whereClauses);

        $sql = "SELECT $columns FROM `$table` WHERE $whereSql ORDER BY $orderBy LIMIT $offset, $limit";
        $result = $conn->query($sql);
        
        if(!$result) { echo json_encode(["status" => "error", "message" => $conn->error]); return; }
        
        $data = [];
        while ($row = $result->fetch_assoc()) $data[] = $row;
        
        $countSql = "SELECT COUNT(*) as total FROM `$table` WHERE $whereSql";
        $total = $conn->query($countSql)->fetch_assoc()['total'];

        echo json_encode([
            "status" => "success", "data" => $data,
            "meta" => ["current_page" => $page, "total_items" => $total]
        ]);
        return;
    }

    // --- CREATE (INSERT) ---
    if ($action === 'create') {
        $input = getJsonInput();
        unset($input['api_key'], $input['action'], $input['resource']); // Cleanup
        
        if(empty($input)) {
            echo json_encode(["status" => "error", "message" => "No data provided"]); return;
        }

        $cols = []; $vals = [];
        foreach($input as $k => $v) {
            $cols[] = "`" . $conn->real_escape_string($k) . "`";
            $vals[] = "'" . $conn->real_escape_string($v) . "'";
        }

        $sql = "INSERT INTO `$table` (" . implode(',', $cols) . ") VALUES (" . implode(',', $vals) . ")";
        if($conn->query($sql)) {
            echo json_encode(["status" => "success", "message" => "Created", "id" => $conn->insert_id]);
        } else {
            echo json_encode(["status" => "error", "message" => $conn->error]);
        }
        return;
    }

    // --- UPDATE ---
    if ($action === 'update') {
        $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
        if(!$id) { echo json_encode(["status" => "error", "message" => "Missing ID"]); return; }

        $input = getJsonInput();
        unset($input['api_key'], $input['action'], $input['resource'], $input['id']);

        $updates = [];
        foreach($input as $k => $v) {
            $updates[] = "`" . $conn->real_escape_string($k) . "` = '" . $conn->real_escape_string($v) . "'";
        }

        $sql = "UPDATE `$table` SET " . implode(', ', $updates) . " WHERE id = $id";
        if($conn->query($sql)) {
            echo json_encode(["status" => "success", "message" => "Updated"]);
        } else {
            echo json_encode(["status" => "error", "message" => $conn->error]);
        }
        return;
    }

    // --- DELETE ---
    if ($action === 'delete') {
        $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
        if(!$id) { echo json_encode(["status" => "error", "message" => "Missing ID"]); return; }

        $sql = "DELETE FROM `$table` WHERE id = $id";
        if($conn->query($sql)) {
            echo json_encode(["status" => "success", "message" => "Deleted"]);
        } else {
            echo json_encode(["status" => "error", "message" => $conn->error]);
        }
        return;
    }
}
?>
