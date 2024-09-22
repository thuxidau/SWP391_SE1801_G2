
package DAL;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DBContext {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/DBProjectSWP391_V1?zeroDateTimeBehavior=CONVERT_TO_NULL";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "dung1234";

    protected static Connection connection;

    public DBContext() {
        // Khởi tạo kết nối đến cơ sở dữ liệu
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
        } catch (ClassNotFoundException | SQLException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    public static Connection getConnection() {
        if (connection == null) {
            new DBContext(); 
        }
        return connection;
    }

    public static void closeConnection() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
            }
        } catch (SQLException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    
    // Hàm kiểm tra kết nối
    public static boolean testConnection() {
        Connection conn = null;
        boolean isConnected = false;
        try {
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            if (conn != null && !conn.isClosed()) {
                isConnected = true;
            }
        } catch (SQLException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, "Connection test failed", ex);
        } finally {
            // Đóng kết nối nếu nó được mở
            try {
                if (conn != null && !conn.isClosed()) {
                    conn.close();
                }
            } catch (SQLException ex) {
                Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, "Failed to close the connection", ex);
            }
        }
        return isConnected;
    }
    
    public static void main(String[] args) {
        if(testConnection()){
            System.out.println("Success");
        }else{
            System.out.println("failed");
        }
    }
}

