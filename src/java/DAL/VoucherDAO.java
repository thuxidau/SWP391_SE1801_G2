package DAL;

import static DAL.DBContext.connection;
import Model.Voucher;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class VoucherDAO extends DBContext {

    public List<Voucher> getListVoucher() {
        List<Voucher> dataVoucher = new ArrayList<>();
        String sql = "SELECT `voucher`.`ID`,\n"
                + "    `voucher`.`Title`,\n"
                + "    `voucher`.`PurchaseOffer`,\n"
                + "    `voucher`.`ApplyDescription`,\n"
                + "    `voucher`.`Image`,\n"
                + "    `voucher`.`ApplyBrandID`,\n"
                + "    `voucher`.`ApplyProductID`,\n"
                + "    `voucher`.`FromDate`,\n"
                + "    `voucher`.`ToDate`,\n"
                + "    `voucher`.`PriceFrom`,\n"
                + "    `voucher`.`Discount`,\n"
                + "    `voucher`.`DiscountMax`,\n"
                + "    `voucher`.`Quantity`,\n"
                + "    `voucher`.`CreatedAt`,\n"
                + "    `voucher`.`UpdatedAt`,\n"
                + "    `voucher`.`DeletedAt`,\n"
                + "    `voucher`.`IsDelete`,\n"
                + "    `voucher`.`DeletedBy`\n"
                + "FROM `dbprojectswp391_v1`.`voucher`"
                + "WHERE `voucher`.`IsDelete` = 0";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            ResultSet rs = st.executeQuery();
            while (rs.next()) {
                Voucher voucher = new Voucher(rs.getInt("ID"),
                        rs.getString("Title"),
                        rs.getString("PurchaseOffer"),
                        rs.getString("ApplyDescription"),
                        rs.getString("Image"),
                        rs.getInt("ApplyBrandID"),
                        rs.getInt("ApplyProductID"),
                        rs.getDate("FromDate"),
                        rs.getDate("ToDate"),
                        rs.getDouble("PriceFrom"),
                        rs.getDouble("Discount"),
                        rs.getDouble("DiscountMax"),
                        rs.getInt("Quantity"),
                        rs.getDate("CreatedAt"),
                        rs.getDate("UpdatedAt"),
                        rs.getDate("DeletedAt"),
                        rs.getBoolean("IsDelete"),
                        rs.getInt("DeletedBy"));
                dataVoucher.add(voucher);
            }
            return dataVoucher;
        } catch (Exception e) {
        }
        return null;
    }

    public List<Voucher> getListVoucherAdmin() {
        List<Voucher> dataVoucher = new ArrayList<>();
        String sql = "SELECT `voucher`.`ID`,\n"
                + "    `voucher`.`Title`,\n"
                + "    `voucher`.`PurchaseOffer`,\n"
                + "    `voucher`.`ApplyDescription`,\n"
                + "    `voucher`.`Image`,\n"
                + "    `voucher`.`ApplyBrandID`,\n"
                + "    `voucher`.`ApplyProductID`,\n"
                + "    `voucher`.`FromDate`,\n"
                + "    `voucher`.`ToDate`,\n"
                + "    `voucher`.`PriceFrom`,\n"
                + "    `voucher`.`Discount`,\n"
                + "    `voucher`.`DiscountMax`,\n"
                + "    `voucher`.`Quantity`,\n"
                + "    `voucher`.`CreatedAt`,\n"
                + "    `voucher`.`UpdatedAt`,\n"
                + "    `voucher`.`DeletedAt`,\n"
                + "    `voucher`.`IsDelete`,\n"
                + "    `voucher`.`DeletedBy`\n"
                + "FROM `dbprojectswp391_v1`.`voucher`";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            ResultSet rs = st.executeQuery();
            while (rs.next()) {
                Voucher voucher = new Voucher(rs.getInt("ID"),
                        rs.getString("Title"),
                        rs.getString("PurchaseOffer"),
                        rs.getString("ApplyDescription"),
                        rs.getString("Image"),
                        rs.getInt("ApplyBrandID"),
                        rs.getInt("ApplyProductID"),
                        rs.getDate("FromDate"),
                        rs.getDate("ToDate"),
                        rs.getDouble("PriceFrom"),
                        rs.getDouble("Discount"),
                        rs.getDouble("DiscountMax"),
                        rs.getInt("Quantity"),
                        rs.getDate("CreatedAt"),
                        rs.getDate("UpdatedAt"),
                        rs.getDate("DeletedAt"),
                        rs.getBoolean("IsDelete"),
                        rs.getInt("DeletedBy"));
                dataVoucher.add(voucher);
            }
            return dataVoucher;
        } catch (Exception e) {
        }
        return null;
    }

    public Voucher getVoucherByID(int voucherId) {
        String sql = "SELECT `voucher`.`ID`,\n"
                + "    `voucher`.`Title`,\n"
                + "    `voucher`.`PurchaseOffer`,\n"
                + "    `voucher`.`ApplyDescription`,\n"
                + "    `voucher`.`Image`,\n"
                + "    `voucher`.`ApplyBrandID`,\n"
                + "    `voucher`.`ApplyProductID`,\n"
                + "    `voucher`.`FromDate`,\n"
                + "    `voucher`.`ToDate`,\n"
                + "    `voucher`.`PriceFrom`,\n"
                + "    `voucher`.`Discount`,\n"
                + "    `voucher`.`DiscountMax`,\n"
                + "    `voucher`.`Quantity`,\n"
                + "    `voucher`.`CreatedAt`,\n"
                + "    `voucher`.`UpdatedAt`,\n"
                + "    `voucher`.`DeletedAt`,\n"
                + "    `voucher`.`IsDelete`,\n"
                + "    `voucher`.`DeletedBy`\n"
                + "FROM `dbprojectswp391_v1`.`voucher`"
                + "WHERE `voucher`.`IsDelete` = 0 AND `voucher`.`ID` = ?";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setInt(1, voucherId);
            ResultSet rs = st.executeQuery();
            Voucher voucher = new Voucher();
            while (rs.next()) {
                voucher = new Voucher(rs.getInt("ID"),
                        rs.getString("Title"),
                        rs.getString("PurchaseOffer"),
                        rs.getString("ApplyDescription"),
                        rs.getString("Image"),
                        rs.getInt("ApplyBrandID"),
                        rs.getInt("ApplyProductID"),
                        rs.getDate("FromDate"),
                        rs.getDate("ToDate"),
                        rs.getDouble("PriceFrom"),
                        rs.getDouble("Discount"),
                        rs.getDouble("DiscountMax"),
                        rs.getInt("Quantity"),
                        rs.getDate("CreatedAt"),
                        rs.getDate("UpdatedAt"),
                        rs.getDate("DeletedAt"),
                        rs.getBoolean("IsDelete"),
                        rs.getInt("DeletedBy"));
            }
            return voucher;
        } catch (SQLException e) {
            System.out.println(e);
        }
        return null;
    }

    public boolean checkExistVoucher(String title) {
        String sql = "SELECT `voucher`.`ID`,\n"
                + "    `voucher`.`Title`,\n"
                + "    `voucher`.`PurchaseOffer`,\n"
                + "    `voucher`.`ApplyDescription`,\n"
                + "    `voucher`.`Image`,\n"
                + "    `voucher`.`ApplyBrandID`,\n"
                + "    `voucher`.`ApplyProductID`,\n"
                + "    `voucher`.`FromDate`,\n"
                + "    `voucher`.`ToDate`,\n"
                + "    `voucher`.`PriceFrom`,\n"
                + "    `voucher`.`Discount`,\n"
                + "    `voucher`.`DiscountMax`,\n"
                + "    `voucher`.`Quantity`,\n"
                + "    `voucher`.`CreatedAt`,\n"
                + "    `voucher`.`UpdatedAt`,\n"
                + "    `voucher`.`DeletedAt`,\n"
                + "    `voucher`.`IsDelete`,\n"
                + "    `voucher`.`DeletedBy`\n"
                + "FROM `dbprojectswp391_v1`.`voucher`"
                + "WHERE `voucher`.`Title` = ?";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setString(1, title);
            ResultSet rs = st.executeQuery();
            if (rs.next()) {
                return false;
            }

        } catch (SQLException e) {
            System.out.println(e);
        }
        return true;
    }

    public void updateQuantityVoucher(int voucherId) {
        String sql = "UPDATE `dbprojectswp391_v1`.`voucher` "
                + "SET `Quantity` = `Quantity` - 1 "
                + "WHERE `ID` = ?;";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setInt(1, voucherId);
            st.executeUpdate();
        } catch (SQLException e) {
            System.out.println(e);
        }
    }

    public boolean addVoucher2(Voucher vou) {
        String sql = "INSERT INTO `dbprojectswp391_v1`.`voucher` "
                + "(`Title`, `PurchaseOffer`, `ApplyDescription`, `Image`, `ApplyBrandID`, `ApplyProductID`, `FromDate`, `ToDate`, `PriceFrom`, `Discount`, `DiscountMax`, `Quantity`, `CreatedAt`) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";

        try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
            pstmt.setString(1, vou.getTitle());
            pstmt.setString(2, vou.getPurchaseOffer());
            pstmt.setString(3, vou.getApplyDescription());
            pstmt.setString(4, vou.getImage());
            pstmt.setInt(5, vou.getApplyBrandID());
            pstmt.setInt(6, vou.getApplyProductID());
            pstmt.setDate(7, new java.sql.Date(vou.getFromDate().getTime()));
            pstmt.setDate(8, new java.sql.Date(vou.getToDate().getTime()));
            pstmt.setDouble(9, vou.getPricefrom());
            pstmt.setDouble(10, vou.getDiscount());
            pstmt.setDouble(11, vou.getDiscountMax());
            pstmt.setInt(12, vou.getQuantity());

            int affectedRows = pstmt.executeUpdate();
            System.out.println(affectedRows);
            return affectedRows > 0;
        } catch (SQLException e) {
            System.err.println("SQL Error: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean addVoucher3(String title, String purchase, String applydesc, String image, int brandid, int productid, Date FromDate, Date Todate, double pricef, double  discount, double discountmax, int quantity) {
        String sql = "INSERT INTO `dbprojectswp391_v1`.`voucher` "
                + "(`Title`, `PurchaseOffer`, `ApplyDescription`, `Image`, `ApplyBrandID`, `ApplyProductID`, `FromDate`, `ToDate`, `PriceFrom`, `Discount`, `DiscountMax`, `Quantity`, `CreatedAt`) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";

        try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
            pstmt.setString(1, title);
            pstmt.setString(2, purchase);
            pstmt.setString(3, applydesc);
            pstmt.setString(4, image);
            pstmt.setInt(5, brandid);
            pstmt.setInt(6, productid);
            pstmt.setDate(7,FromDate);
            pstmt.setDate(8, Todate);
            pstmt.setDouble(9, pricef);
            pstmt.setDouble(10, discount);
            pstmt.setDouble(11, discountmax);
            pstmt.setInt(12, quantity);

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            System.err.println("SQL Error: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public static void main(String[] args) {
        VoucherDAO u = new VoucherDAO();
        LocalDate currentDate = LocalDate.now();
        java.sql.Date sqlDate = java.sql.Date.valueOf(currentDate);
        Voucher v = new Voucher("A", "B", "C", "viettel_logo.jpg", 1, 1, sqlDate, sqlDate, 1000, 10, 10, 10);
        //Voucher v1 = new Voucher();
        System.out.println(u.addVoucher2(v));
    }
}
