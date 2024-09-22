package DAL;

import static DAL.DBContext.connection;
import Model.CategoriesNews;
import Model.RegisterNotification;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class RegisterNotificationDAO extends DBContext {

    public void insertRegisterNotification(RegisterNotification register) {
        String sql = "INSERT INTO `dbprojectswp391_v1`.`regiternotification` "
                + "(`Name`, `Email`, `Message`, `CreatedAt`) "
                + "VALUES (?, ?, ?, NOW())";
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, register.getName());
            ps.setString(2, register.getEmail());
            ps.setString(3, register.getMessage());
            ps.executeUpdate();
        } catch (SQLException e) {
            System.out.println(e);
        }
    }

    public boolean getEmailRegistered(String email) {
        String sql = "SELECT `regiternotification`.`ID`,\n"
                + "    `regiternotification`.`Name`,\n"
                + "    `regiternotification`.`Email`,\n"
                + "    `regiternotification`.`Message`,\n"
                + "    `regiternotification`.`CreatedAt`,\n"
                + "    `regiternotification`.`UpdatedAt`,\n"
                + "    `regiternotification`.`DeletedAt`,\n"
                + "    `regiternotification`.`IsDelete`,\n"
                + "    `regiternotification`.`DeletedBy`\n"
                + "FROM `dbprojectswp391_v1`.`regiternotification`"
                + "WHERE `regiternotification`.`Email` = ?";
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                return false;
            }
        } catch (SQLException e) {
            System.out.println(e);
        }
        return true;
    }

    public static void main(String[] args) {
        RegisterNotificationDAO u = new RegisterNotificationDAO();
        RegisterNotification r = new RegisterNotification(1,
                 "ABC", "abc", null, null,
                 null, null, false, 0);
        //u.insertRegisterNotification(r);
        
    }
}
