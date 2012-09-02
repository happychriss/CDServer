
## Create a double linke list, requieres prev_id and next_id in the database, works as mixing
module DoubleLinkedList
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    ## array of ids of objects to included in list
    def BuildList(new_list)
      return false if new_list.count<=2
      for i in 0..new_list.count-1
        obj=self.find(new_list[i])
        if i==0 then
          obj.next_id=new_list[i+1]
          obj.prev_id=nil
        elsif i=new_list.count-1 then
          obj.next_id=nil
          obj.prev_id=new_list[i-1]
        else
          obj.next_id=new_list[i+1]
          obj.prev_id=new_list[i-1]
        end
        obj.save
      end
    end
  end

  ################ Helper


  def next_obj
    return nil if self.next_id.nil?
    return self.class.find(self.next_id)
  end

  def prev_obj
    return nil if self.prev_id.nil?
    return self.class.find(self.prev_id)
  end

#####################

  def append(obj)
    n = self
    until n.next_id.nil?
      n = n.next_obj
      if n.id==obj.id then
        raise Exception "DoubleList Error"
      end
    end

    n.next_id = obj.id
    n.save!

    obj.prev_id=n.id
    obj.next_id=nil
    obj.save!

  end
##################################################
  def head
    n = self
    until n.prev_id.nil?
      n = n.prev_obj
    end
    return n
  end
#################################################
  def remove
    n=self.next_obj
    p=self.prev_obj

    ## first node
    if p.nil?
      n.prev_id=nil
      n.save!
      ## last node
    elsif n.nil?
      p.next_id=nil
      p.save!
    else
      p.next_id=n.id
      n.prev_id=p.id
      n.save!
      p.save!
    end

    self.prev_id=nil
    self.next_id=nil
    self.save!
  end

  ### insert obj after self
  def insert(obj)
    n=self.next_obj
    if n.nil?
      append(obj)
    else
       ## Update inserted object
      obj.prev_id=self.id
      obj.next_id=n.id
      obj.save!

      ### updated myself
      self.next_id=obj.id
      self.save!

      ## update previous
      n.prev_id=obj.id
      n.save!
    end
  end

  def GetList
    list=Array.new
    my_head=self.head
    return nil if my_head.nil?

    n = head
    until n.next_id.nil?
      list.push(n.id)
      n = n.next_obj
    end
    list.push(n.id)

    return list
  end

  def BuildList(arr)
    obj=n=self.class.find(arr.first)

  end

end