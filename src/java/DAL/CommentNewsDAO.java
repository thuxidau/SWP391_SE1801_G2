
package DAL;

import Model.CommentNews;
import Model.RegisterNotification;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class CommentNewsDAO extends DBContext{
    public void insertCommentNews(CommentNews comment) {
        String sql = "INSERT INTO `dbprojectswp391_v1`.`commentnews`"
                + "(`Name`, `Email`, `Message`, `NewsID`, `CreatedAt`) "
                + "VALUES (?, ?, ?, ?, NOW())";
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, comment.getName());
            ps.setString(2, comment.getEmail());
            ps.setString(3, comment.getMessage());
            ps.setInt(4, comment.getNewsId());
            ps.executeUpdate();
        } catch (SQLException e) {
            System.out.println(e);
        }
    }
    
    
}
