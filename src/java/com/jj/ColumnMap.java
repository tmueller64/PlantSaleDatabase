package com.jj;

/**
 * A map from the columns in the on-line order input file to the data fields.
 */
public class ColumnMap {
    int date;
    int seller;
    int products;
    int transaction;
    int customer;
    int firstName;
    int lastName;
    int email;
    int address;
    int city;
    int state;
    int zip;
    int phone;
    int maxColumn = 0;
    
    public ColumnMap() {
    }

    public int getDate() {
        return date;
    }

    public void setDate(int date) {
        setMaxColumn(date);
        this.date = date;
    }

    public int getSeller() {
        return seller;
    }

    public void setSeller(int seller) {
        setMaxColumn(seller);
        this.seller = seller;
    }

    public int getProducts() {
        return products;
    }

    public void setProducts(int products) {
        setMaxColumn(products);
        this.products = products;
    }

    public int getTransaction() {
        return transaction;
    }

    public void setTransaction(int transaction) {
        setMaxColumn(transaction);
        this.transaction = transaction;
    }

    public int getCustomer() {
        return customer;
    }

    public void setCustomer(int customer) {
        setMaxColumn(customer);
        this.customer = customer;
    }
    
    public int getFirstName() {
        return firstName;
    }

    public void setFirstName(int firstName) {
        setMaxColumn(firstName);
        this.firstName = firstName;
    }

    public int getLastName() {
        return lastName;
    }

    public void setLastName(int lastName) {
        setMaxColumn(lastName);
        this.lastName = lastName;
    }

    public int getEmail() {
        return email;
    }

    public void setEmail(int email) {
        setMaxColumn(email);
        this.email = email;
    }

    public int getAddress() {
        return address;
    }

    public void setAddress(int address) {
        setMaxColumn(address);
        this.address = address;
    }

    public int getCity() {
        return city;
    }

    public void setCity(int city) {
        setMaxColumn(city);
        this.city = city;
    }

    public int getState() {
        return state;
    }

    public void setState(int state) {
        setMaxColumn(state);
        this.state = state;
    }

    public int getZip() {
        return zip;
    }

    public void setZip(int zip) {
        setMaxColumn(zip);
        this.zip = zip;
    }

    public int getPhone() {
        return phone;
    }

    public void setPhone(int phone) {
        setMaxColumn(phone);
        this.phone = phone;
    }
    
    public int getMaxColumn() {
        return maxColumn;
    }
    
    private void setMaxColumn(int column) {
        if (column > maxColumn) {
            maxColumn = column;
        }
    }
}
